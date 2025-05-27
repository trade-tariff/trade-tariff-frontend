# SPQ is a complementary evaluator for the SPQ measurement unit on excise measure components
# It is the only evaluator that needs to reference the other components in the measure condition
#
# It cannot exist in a non-compound (non-multi-component form)
#
# It has two modes of operation:
#   1. LPA-based (where the other components are LPA we will use the LPA answer)
#   2. ASVX-based (where the other components are ASVX we will use the ASVX answer)
module ExpressionEvaluators
  class Spq < ExpressionEvaluators::Base
    include MeasureUnitPresentable

    def call
      {
        calculation: measure_condition.duty_expression,
        value:,
        formatted_value: number_to_currency(value),
      }
    end

    private

    def value
      @value ||= begin
        candidate_value = if measure_condition.lpa_based?
                            lpa_value
                          elsif measure_condition.asvx_based?
                            asvx_value
                          end

        candidate_value.present? ? candidate_value.to_f.floor(2) : 0.0
      end
    end

    def lpa_value
      component.duty_amount * lpa_answer * spr_answer
    end

    def asvx_value
      component.duty_amount * asv_answer * hlt_answer * spr_answer
    end

    def asv_answer
      coerced_answer_for(applicable_units[Api::BaseComponent::ALCOHOL_UNIT])
    end

    def hlt_answer
      coerced_answer_for(applicable_units[Api::BaseComponent::HECTOLITERS_UNIT])
    end

    def spr_answer
      coerced_answer_for(applicable_units[Api::BaseComponent::SPR_DISCOUNT_UNIT])
    end

    def lpa_answer
      coerced_answer_for(applicable_units[Api::BaseComponent::LITERS_PURE_ALCOHOL_UNIT])
    end
  end
end
