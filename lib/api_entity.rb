require 'multi_json'
require 'active_model'
require 'tariff_jsonapi_parser'
require 'unparseable_response_error'

module ApiEntity
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Conversion
    include ActiveModel::Validations
    extend  ActiveModel::Naming

    include Faraday
    include MultiJson

    attr_reader :resource_id, :attributes
    attr_writer :resource_type

    attr_accessor :casted_by

    delegate :relationships, to: :class
    delegate :[], :dig, to: :attributes

    def inspect
      attrs = if defined?(@attributes) && @attributes.any?
                attributes_for_inspect
              else
                instance_variables_for_inspect
              end

      inspection = attrs.any? ? attrs.join(', ') : 'not initialised'

      "#<#{self.class.name.presence || self.class} #{inspection}>"
    end

    def resource_path
      "#{self.class.nested_name}/#{to_param}"
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
    @resource_id ||= resource_id
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

  def hydrate_errors_from_response(error)
    body = error.response&.dig(:body)
    return if body.nil?

    body = JSON.parse(body) if body.is_a?(String)
    api_errors = body['errors']
    return unless api_errors.is_a?(Array)

    api_errors.each do |api_error|
      attribute = attribute_from_pointer(api_error.dig('source', 'pointer'))
      detail = api_error['detail'] || api_error['title'] || 'is invalid'
      errors.add(attribute, detail)
    end
  rescue JSON::ParserError
    errors.add(:base, 'The service returned an invalid response')
  end

private

  def attribute_from_pointer(pointer)
    return :base if pointer.blank?

    pointer.split('/').last.to_sym
  end

  def attributes_for_inspect
    @attributes.except(*(relationships.to_a + [:casted_by]))
               .map { |k, v| "#{k}: #{v.inspect}" }
  end

  def instance_variables_for_inspect
    instance_variables.without(%i[@attributes @casted_by])
                      .map { |k| k.to_s.sub('@', '') }
                      .select(&method(:respond_to?))
                      .map { |k| "#{k}: #{public_send(k).inspect}" }
  end

  module ClassMethods
    delegate :get, :post, to: :api

    def create!(params = {}, headers = {})
      request = prepare_json_request(params, headers)
      response = api.post(singular_path, request[:body], request[:headers])
      new parse_jsonapi(response)
    end

    def batch(id, params = {}, headers = {})
      request = prepare_json_request(params, headers)
      batch_path = "#{singular_path.sub(':id', id)}/batch"
      response = api.post(batch_path, request[:body], request[:headers])
      new parse_jsonapi(response)
    end

    def update(params = {}, headers = {})
      request = prepare_json_request(params, headers)
      response = api.put(singular_path, request[:body], request[:headers])
      new parse_jsonapi(response)
    end

    def relationships
      @relationships ||= superclass.include?(ApiEntity) ? superclass.relationships.dup : []
    end

    def find(id, opts = {}, headers = {})
      id = id.to_s
      path = singular_path.sub(':id', id)

      response = api.get(path, opts, headers)

      new parse_jsonapi(response)
    end

    def delete(id)
      path = singular_path.sub(':id', id.to_s)
      api.delete(path)
    end

    def all(opts = {})
      collection(collection_path, opts)
    end

    def search(opts = {})
      collection("#{collection_path}/search", opts)
    end

    def collection(collection_path, opts = {}, headers = {})
      begin
        resp = api.get(collection_path, opts, headers)
      rescue Faraday::TimeoutError => e
        Rails.logger.error("Timeout calling #{collection_path}: #{e.message}")
        raise
      end
      collection = parse_jsonapi(resp)
      collection = collection.map { |entry_data| new(entry_data) }
      if resp.body.is_a?(Hash) && resp.body.dig('meta', 'pagination').present?
        collection = paginate_collection(collection, resp.body.dig('meta', 'pagination'))
      end
      collection
    rescue Faraday::Error => e
      Rails.logger.error("Faraday error: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end

    def has_one(association, opts = {})
      options = {
        class_name: association.to_s.singularize.classify,
        polymorphic: false,
      }.merge(opts)

      relationships << association

      attr_reader association.to_sym

      define_method("#{association}=") do |attributes|
        entity = if attributes.nil?
                   nil
                 else
                   class_name = if options[:polymorphic].is_a?(Hash)
                                  options[:polymorphic][attributes['resource_type']] || raise('Unspecified polymorphic resource type')
                                elsif options[:polymorphic]
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
      options = {
        class_name: association.to_s.singularize.classify,
        polymorphic: false,
      }.merge(opts)

      relationships << association

      define_method(association) do
        collection = instance_variable_get("@#{association}").presence || []
        collection = options[:wrapper].new(collection) if options[:wrapper]

        if options[:filter].present?
          collection.public_send(options[:filter])
        else
          collection
        end
      end

      define_method("#{association}=") do |data|
        data = data.presence || []

        collection = data.map do |attributes|
          class_name = if options[:polymorphic].is_a?(Hash)
                         options[:polymorphic][attributes['resource_type']] || raise('Unspecified polymorphic resource type')
                       elsif options[:polymorphic]
                         attributes['resource_type'].classify
                       else
                         options[:class_name]
                       end

          entity = class_name.constantize.new((attributes.presence || {}).merge(casted_by: self))

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
      enum_config.each do |method_name, values|
        define_method("#{method_name}?") do
          result = public_send(field)

          if result.present?
            values.include?(result)
          else
            false
          end
        end
      end
    end

    def meta_attribute(*attribute_path)
      attribute_path = attribute_path.map(&:to_s)
      method_name = attribute_path.last

      define_method(method_name) do
        meta.dig(*attribute_path)
      end
    end

    def paginate_collection(collection, pagination)
      Kaminari.paginate_array(
        collection,
        total_count: pagination['total_count'],
      ).page(pagination['page']).per(pagination['per_page'])
    end

    def singular_path
      @singular_path ||= "#{nested_name}/:id"
    end

    def set_singular_path(path)
      @singular_path = path
    end

    def collection_path
      @collection_path ||= nested_name
    end

    def set_collection_path(path)
      @collection_path = path
    end

    def api
      TradeTariffFrontend::ServiceChooser.api_client
    end

    def nested_name
      @nested_name ||= begin
        parts = name.split('::').map(&:underscore)
        *namespaces, resource = parts
        resource = resource.pluralize
        (namespaces + [resource]).join('/')
      end
    end

    def parse_jsonapi(resp)
      TariffJsonapiParser.new(resp.body).parse
    rescue TariffJsonapiParser::ParsingError
      raise UnparseableResponseError, resp
    end

    def prepare_json_request(params, headers)
      {
        body: MultiJson.dump(params),
        headers: headers.merge('Content-Type' => 'application/json'),
      }
    end
  end
end
