require 'api_entity'

class Search
  class BaseMatch
    include ApiEntity

    class << self
      private

      def array_attr_reader(*args)
        args.each do |arg|
          define_method(arg.to_sym) do
            instance_variable_get("@#{arg}").presence || []
          end
        end
      end

      def array_attr_writer(*names)
        names.each do |name|
          define_method("#{name}=") do |entry_data|
            instance_variable_set(
              "@#{name}",
              entry_data.map do |ed|
                klass = name.to_s.singularize.capitalize.constantize

                attributes = if ed['_source'].key?('reference')
                               ed['_source']['reference']
                             else
                               ed['_source']
                             end

                attributes['score'] = ed['_score'] if ed['_score'].present?

                klass.new(attributes)
              end,
            )
          end
        end
      end
    end
  end
end
