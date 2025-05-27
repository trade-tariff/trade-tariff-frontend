module ExpressionEvaluators
  class SucroseMeasureUnit < ExpressionEvaluators::Base
    include MeasureUnitPresentable

    def call
      {
        calculation: sanitized_duty_expression,
        value:,
        formatted_value: number_to_currency(value),
      }
    end

    private

    def sanitized_duty_expression
      expression = measure_condition&.duty_expression || measure.duty_expression.formatted_base

      sanitize(expression, tags: %w[span abbr], attributes: %w[title])
    end

    def value
      candidate_value = component.duty_amount * quantity_in_decitonnes * sucrose_quantity

      if component.euros?
        candidate_value * euro_exchange_rate
      else
        candidate_value
      end
    end

    def quantity_in_decitonnes
      presented_decitonne_unit[:answer].to_f * presented_decitonne_unit[:multiplier].to_f
    end

    def sucrose_quantity
      presented_sucrose_unit[:answer].to_f
    end

    def decitonne_unit
      applicable_units[Api::BaseComponent::DECITONNE_UNIT]
    end

    def sucrose_unit
      applicable_units[Api::BaseComponent::SUCROSE_UNIT]
    end

    def presented_decitonne_unit
      @presented_decitonne_unit ||= {
        answer: unit_answer_for(decitonne_unit),
        unit: decitonne_unit['unit'],
        multiplier: decitonne_unit_multiplier,
      }
    end

    def presented_sucrose_unit
      @presented_sucrose_unit ||= {
        answer: unit_answer_for(sucrose_unit),
        unit: sucrose_unit['unit'],
      }
    end

    def decitonne_unit_multiplier
      decitonne_unit['multiplier'].presence || 1
    end
  end
end
