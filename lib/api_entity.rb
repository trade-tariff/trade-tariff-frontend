require 'faraday_middleware'
require 'multi_json'
require 'active_model'
require 'tariff_jsonapi_parser'

module ApiEntity
  class UnparseableResponseError < StandardError
    def initialize(response)
      @response = response

      super message
    end

    def message
      "Error parsing #{url} with headers: #{headers.inspect}"
    end

    private

    def headers
      @response.env[:request_headers]
    end

    def url
      @response.env[:url]
    end
  end

  extend ActiveSupport::Concern

  included do
    include ActiveModel::Conversion
    extend  ActiveModel::Naming

    include Faraday
    include MultiJson

    attr_reader :resource_id, :attributes
    attr_writer :resource_type

    attr_accessor :casted_by

    cattr_accessor :relationships

    delegate :relationships, to: :class

    def inspect
      if @attributes.blank?
        candidate_variables = instance_variables - %i[@attributes @casted_by]

        candidate_variables.each_with_object({}) do |variable, acc|
          key = variable.to_s.sub('@', '')
          acc[key] = public_send(key)
        end
      else
        keys_to_exclude = relationships.to_a + [:casted_by]

        @attributes.except(*keys_to_exclude)
      end
    end

    def resource_path
      "/#{self.class.name.underscore.pluralize}/#{to_param}"
    end

    def to_param
      id
    end

    def resource_type
      @attributes['resource_type'] || self.class.name.underscore.singularize
    end
  end

  def initialize(attributes = {})
    attributes = HashWithIndifferentAccess.new(attributes)

    self.attributes = attributes
  end

  def resource_id=(resource_id)
    @resource_id ||= resource_id # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def attributes=(attributes = {})
    @attributes = attributes

    attributes.each do |name, value|
      if respond_to?(:"#{name}=")
        public_send(:"#{name}=", value)
      end
    end
  end

  def persisted?
    true
  end

  module ClassMethods
    delegate :get, :post, to: :api

    def find(id, opts = {})
      retries = 0
      begin
        resp = api.get("/#{name.pluralize.underscore}/#{id}", opts)
        new parse_jsonapi(resp)
      rescue Faraday::Error, ApiEntity::UnparseableResponseError
        if retries < Rails.configuration.x.http.max_retry
          retries += 1
          retry
        else
          raise
        end
      end
    end

    def all(opts = {})
      collection(collection_path, opts)
    end

    def search(opts = {})
      collection("#{collection_path}/search", opts)
    end

    def collection(collection_path, opts = {})
      retries = 0
      begin
        resp = api.get(collection_path, opts)
        collection = parse_jsonapi(resp)
        collection = collection.map { |entry_data| new(entry_data) }
        collection = paginate_collection(collection, resp.body.dig('meta', 'pagination')) if resp.body.is_a?(Hash) && resp.body.dig('meta', 'pagination').present?
        collection
      rescue Faraday::Error, ApiEntity::UnparseableResponseError
        if retries < Rails.configuration.x.http.max_retry
          retries += 1
          retry
        else
          raise
        end
      end
    end

    def has_one(association, opts = {})
      options = {
        class_name: association.to_s.singularize.classify,
        polymorphic: false,
      }.merge(opts)

      (self.relationships ||= []) << association

      attr_reader association.to_sym

      define_method("#{association}=") do |attributes|
        entity = if attributes.nil?
                   nil
                 else
                   class_name = if options[:polymorphic]
                                  attributes['resource_type'].classify
                                else
                                  options[:class_name]
                                end
                   class_name.constantize.new((attributes.presence || {}).merge(casted_by: self))
                 end

        instance_variable_set("@#{association}", entity)
      end
    end

    def has_many(association, opts = {})
      options = opts.reverse_merge(class_name: association.to_s.singularize.classify, wrapper: Array)

      (self.relationships ||= []) << association

      define_method(association) do
        collection = instance_variable_get("@#{association}").presence || []
        collection = options[:wrapper].new(collection)

        if options[:filter].present?
          collection.public_send(options[:filter])
        else
          collection
        end
      end

      define_method("#{association}=") do |data|
        data = data.presence || []

        collection = data.map do |entity_attributes|
          entity_attributes = entity_attributes.merge(casted_by: self)

          entity = options[:class_name].constantize.new(entity_attributes)

          if options[:presenter].present?
            options[:presenter].new(entity)
          else
            entity
          end
        end

        instance_variable_set("@#{association}", collection)
      end

      define_method("add_#{association.to_s.singularize}") do |entity|
        instance_variable_set("@#{association}", []) unless instance_variable_defined?("@#{association}")
        instance_variable_get("@#{association}").public_send('<<', entity)
      end
    end

    def enum(field, enum_config)
      enum_config.each do |method_name, value|
        define_method("#{method_name}?") do
          public_send(field).in?(value)
        end
      end
    end

    def paginate_collection(collection, pagination)
      Kaminari.paginate_array(
        collection,
        total_count: pagination['total_count'],
      ).page(pagination['page']).per(pagination['per_page'])
    end

    def collection_path(path = nil)
      return @collection_path if path.blank?

      @collection_path = path
    end

    def api
      TradeTariffFrontend::ServiceChooser.api_client
    end

    def parse_jsonapi(resp)
      TariffJsonapiParser.new(resp.body).parse
    rescue TariffJsonapiParser::ParsingError
      raise UnparseableResponseError, resp
    end
  end
end
