module ExpressionEvaluators
  class Base
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::SanitizeHelper

    def initialize(measure, component, duty_total = nil)
      @measure = measure
      @component = component
      @duty_total = duty_total
    end

    protected

    attr_reader :measure, :component, :duty_total

    def measure_condition
      candidate_measure_condition_component = measure.applicable_components.first.presence || component

      if candidate_measure_condition_component&.belongs_to_measure_condition?
        measure.measure_conditions.find do |measure_condition|
          measure_condition.id == candidate_measure_condition_component.measure_condition_sid
        end
      end
    end

    def user_session
      UserSession.get
    end

    def euro_exchange_rate
      Api::MonetaryExchangeRate.for('GBP').exchange_rate
    end
  end
end
