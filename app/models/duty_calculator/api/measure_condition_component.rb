module DutyCalculator
  module Api
    class MeasureConditionComponent < Api::BaseComponent
      ID_REGEX = /^(?<measure_condition_sid>(?<optional>-)?\d+)-(?<duty_expression_id>\d+)$/

      def measure_condition_sid
        match_data = id.match(ID_REGEX)

        return unless match_data

        match_data[:measure_condition_sid]
      end

      def belongs_to_measure_condition?
        true
      end
    end
  end
end
