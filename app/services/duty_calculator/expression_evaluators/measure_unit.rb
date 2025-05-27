module ExpressionEvaluators
  class MeasureUnit < ExpressionEvaluators::Base
    include CommodityHelper
    include MeasureUnitPresentable

    def call
      {
        calculation: sanitized_duty_expression,
        value:,
        formatted_value: number_to_currency(value),
        unit: presented_unit[:unit],
        total_quantity:,
        original_unit: presented_unit[:original_unit],
      }
    end

    private

    def sanitized_duty_expression
      expression =
        if measure_condition.present?
          measure_condition.duty_expression
        else
          measure.duty_expression.formatted_base
        end

      sanitize(expression, tags: %w[span abbr], attributes: %w[title])
    end

    def quantity_string
      NumberWithHighPrecisionFormatter.new(total_quantity).call
    end

    def value
      @value ||= begin
        return total_quantity * component.duty_amount * euro_exchange_rate if component.euros?

        total_quantity * component.duty_amount
      end
    end

    def total_quantity
      presented_unit[:answer].to_f * multiplier
    end

    def multiplier
      presented_unit[:multiplier].to_f
    end
  end
end
