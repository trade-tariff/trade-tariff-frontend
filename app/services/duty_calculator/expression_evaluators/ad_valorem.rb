module ExpressionEvaluators
  class AdValorem < ExpressionEvaluators::Base
    def call
      {
        calculation: "#{number_to_percentage(component.duty_amount)} * #{number_to_currency(total_amount)}",
        value:,
        formatted_value: number_to_currency(value),
      }
    end

    private

    def value
      @value ||= total_amount / 100.0 * component.duty_amount
    end

    def total_amount
      user_session.total_amount
    end
  end
end
