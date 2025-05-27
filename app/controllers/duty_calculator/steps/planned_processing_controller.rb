module DutyCalculator
  module Steps
    class PlannedProcessingController < BaseController
      def show
        @step = Steps::PlannedProcessing.new
      end

      def create
        @step = Steps::PlannedProcessing.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        return {} unless params.key?(:steps_planned_processing)

        params.require(:steps_planned_processing).permit(
          :planned_processing,
        )
      end
    end
  end
end
