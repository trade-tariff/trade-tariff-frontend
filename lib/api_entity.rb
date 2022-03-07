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
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend  ActiveModel::Naming

    include Faraday
    include MultiJson

    attr_reader :attributes

    attr_accessor :casted_by

    cattr_accessor :relationships

    delegate :relationships, to: :class

    def inspect
      keys_to_exclude = relationships + [:casted_by]

      @attributes.except(*keys_to_exclude)
    end

    class_eval do
      def resource_path
        "/#{self.class.name.underscore.pluralize}/#{to_param}"
      end

      def to_param
        id
      end
    end
  end

  def initialize(attributes = {})
    class_name = self.class.name.downcase

    attributes = HashWithIndifferentAccess.new(attributes)

    if attributes.present? && attributes.key?(class_name)
      @attributes = attributes[class_name]

      self.attributes = attributes[class_name]
    else
      @attributes = attributes

      self.attributes = attributes
    end
  end

  def attributes=(attributes = {})
    if attributes.present?
      attributes.each do |name, value|
        if respond_to?(:"#{name}=")
          send(:"#{name}=", value.is_a?(String) && value == 'null' ? nil : value)
        end
      end
    end
  end

  def persisted?
    true
  end

  module ClassMethods
    delegate :get, :post, to: :api

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

    def has_one(association, opts = {})
      options = opts.reverse_merge(class_name: association.to_s.singularize.classify)

      attr_accessor association.to_sym

      (self.relationships ||= []) << association

      class_eval <<-METHODS, __FILE__, __LINE__ + 1
        def #{association}=(data)
          data ||= {}

          @#{association} ||= #{options[:class_name]}.new(data.merge(casted_by: self))
        end
      METHODS
    end

    def enum(field, enum_config)
      enum_config.each do |method_name, value|
        define_method("#{method_name}?") do
          public_send(field).in?(value)
        end
      end
    end

    def has_many(association, opts = {})
      options = opts.reverse_merge(class_name: association.to_s.singularize.classify, wrapper: Array)

      (self.relationships ||= []) << association

      class_eval <<-METHODS, __FILE__, __LINE__ + 1
        def #{association}
          collection = #{options[:wrapper]}.new(@#{association}.presence || [])

          if #{options[:filter].present?}
            collection.public_send("#{options[:filter]}")
          else
            collection
          end
        end

        def #{association}=(data)
          @#{association} ||= if data.present?
            data.map { |record| #{options[:class_name]}.new(record.merge(casted_by: self)) }
          else
            []
          end
        end

        def add_#{association.to_s.singularize}(record)
          @#{association} ||= []
          @#{association} << record
        end
      METHODS
    end

    def paginate_collection(collection, pagination)
      Kaminari.paginate_array(
        collection,
        total_count: pagination['total_count'],
      ).page(pagination['page']).per(pagination['per_page'])
    end

    def collection_path(path = nil)
      if path
        @collection_path = path
      else
        @collection_path
      end
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
