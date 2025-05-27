module ExpressionEvaluators
  class Compound < ExpressionEvaluators::Base
    def call
      {
        calculation: sanitized_duty_expression,
        value: evaluation_result,
        formatted_value: number_to_currency(evaluation_result),
      }
    end

    private

    def sanitized_duty_expression
      sanitize(duty_expression, tags: %w[span abbr strong br], attributes: %w[title])
    end

    def duty_expression
      base_duty_expression = if measure_condition.present?
                               measure_condition.duty_expression
                             else
                               measure.duty_expression&.formatted_base
                             end

      if measure.resolved_duty_expression.present?
        "#{base_duty_expression}<br>#{measure.resolved_duty_expression}"
      else
        base_duty_expression
      end
    end

    def build_expression
      measure.applicable_components.flat_map do |component|
        if component.conjunction_operator?
          [
            {
              operator: component.operator,
            },
            {
              operator: '+',
              value: value_for(component),
            },
          ]
        else
          {
            operator: component.operator,
            value: value_for(component),
          }
        end
      end
    end

    def value_for(component)
      evaluator = measure.evaluator_for_compound_component(component)

      evaluator.call[:value]
    end

    def evaluate(expression)
      conjunction_operator = last_conjunction_operator(expression)

      if conjunction_operator.present?
        left_expression = evaluate(expression[0..conjunction_operator[:index] - 1])
        right_expression = evaluate(expression[conjunction_operator[:index] + 1..expression.length - 1])

        case conjunction_operator[:operator]
        when 'MAX' then [left_expression, right_expression].min
        when 'MIN' then [left_expression, right_expression].max
        end
      else
        evaluate_subexpression(expression)
      end
    end

    def evaluate_subexpression(expression)
      expression.reduce(0) do |acc, element|
        case element[:operator]
        when '%' then acc + element[:value]
        when '+' then acc + element[:value]
        when '-' then acc - element[:value]
        end
      end
    end

    def last_conjunction_operator(expression)
      expression.each.with_index.each_with_object({}) do |(e, index), hash|
        if Api::BaseComponent::CONJUNCTION_OPERATORS.include?(e[:operator])
          hash[:index] = index
          hash[:operator] = e[:operator]
        end
      end
    end

    def evaluation_result
      @evaluation_result ||= evaluate(build_expression)
    end
  end
end
