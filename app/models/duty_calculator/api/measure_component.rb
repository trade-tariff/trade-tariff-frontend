module DutyCalculator
  module Api
    class MeasureComponent < Api::BaseComponent
      def belongs_to_measure_condition?
        false
      end
    end
  end
end
