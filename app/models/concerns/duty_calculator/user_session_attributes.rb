module DutyCalculator
  module UserSessionAttributes
    extend ActiveSupport::Concern

    class_methods do
      def attribute(attribute, answer: true)
        define_method(attribute) do
          return session['answers'][attribute.to_s] if answer

          session[attribute.to_s]
        end

        define_method("#{attribute}=") do |value|
          return session['answers'][attribute.to_s] = value if answer

          session[attribute.to_s] = value
        end
      end

      def dual_route_attribute(attribute)
        define_method("#{attribute}_uk") do
          session['answers'][attribute.to_s]['uk']
        end

        define_method("#{attribute}_xi") do
          session['answers'][attribute.to_s]['xi']
        end

        define_method("#{attribute}_uk=") do |value|
          public_send("#{attribute}_uk").merge!(value)
        end

        define_method("#{attribute}_xi=") do |value|
          public_send("#{attribute}_xi").merge!(value)
        end

        define_method("#{attribute}?") do
          public_send("#{attribute}_uk").present? || public_send("#{attribute}_xi").present?
        end
      end

      def answer_attributes(*attributes)
        attributes.each { |attr| attribute attr, answer: true }
      end

      def non_answer_attributes(*attributes)
        attributes.each { |attr| attribute attr, answer: false }
      end

      def attribute_for_uk_and_xi(*attributes)
        attributes.each { |attr| dual_route_attribute attr }
      end
    end
  end
end
