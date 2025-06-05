module DutyCalculator
  module Api
    class Base
      attr_accessor :attributes

      delegate :user_session, to: :class
      delegate :as_json, to: :attributes

      def initialize(attributes = {})
        @attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes.fetch('attributes', attributes))
      end

      delegate :[], to: :attributes

      class << self
        def inherited(child)
          super

          child.attribute :meta
        end

        def attribute(attribute)
          define_method(attribute) do
            attributes[attribute]
          end

          define_method("#{attribute}=") do |value|
            attributes[attribute] = value
          end
        end

        def meta_attribute(*attribute_path)
          attribute_path = attribute_path.map(&:to_s)
          method_name = attribute_path.last

          define_method(method_name) do
            meta.dig(*attribute_path)
          end
        end

        def attributes(*attribute_list)
          attribute_list.each do |resource_attribute|
            attribute resource_attribute
          end
        end

        def has_many(relation, klass)
          attribute relation

          define_method(relation) do
            attributes[relation.to_s].map { |resource_attributes| klass.new(resource_attributes) }
          end
        end

        def has_one(relation, klass)
          attribute relation

          define_method(relation) do
            relation_attributes = attributes[relation.to_s]
            klass.new(relation_attributes) if relation_attributes.present?
          end
        end

        def build(service, id, query = {})
          client = http_client_for(service)
          query = default_query.merge(query)

          resource = "Uktt::#{name.demodulize}".constantize

          resource = resource.new(client)

          resource.retrieve(id, query)

          new(resource.response)
        end

        def build_collection(service, klass_override = nil, query = {})
          client = http_client_for(service)
          query = default_query.merge(query)

          resource = if klass_override.present?
                       "Uktt::#{klass_override.demodulize}".constantize
                     else
                       "Uktt::#{name.demodulize}".constantize
                     end

          resource = resource.new(client)

          resource.retrieve_all(query)

          resource.response.map do |resource_attributes|
            new(resource_attributes)
          end
        end

        def enum(field, enum_config)
          enum_config.each do |method_name, value|
            define_method("#{method_name}?") do
              public_send(field).in?(value)
            end
          end
        end

        def http_client_for(service)
          return Rails.application.config.duty_calculator_http_client_uk if service.to_sym == :uk

          Rails.application.config.duty_calculator_http_client_xi
        end

        def user_session
          UserSession.get
        end

        private

        def default_query
          { 'as_of' => (user_session&.import_date || Time.zone.today).iso8601 }
        end
      end

      def eql?(other)
        as_json == other.as_json
      end
    end
  end
end
