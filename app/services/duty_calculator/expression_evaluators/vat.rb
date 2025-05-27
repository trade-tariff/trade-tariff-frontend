module ExpressionEvaluators
  class Vat < ExpressionEvaluators::Base
    def call
      {
        calculation: "#{number_to_percentage(component.duty_amount)} * #{number_to_currency(duty_plus_total_amount)}",
        value:,
        formatted_value: number_to_currency(value),
      }
    end

    private

    def value
      @value ||= duty_plus_total_amount / 100.0 * component.duty_amount
    end

    def duty_plus_total_amount
      duty_total + user_session.total_amount
    end
  end
end
