module DutyCalculator
  module Steps
    class ImportDestinationController < BaseController
      def show
        @step = ImportDestination.new
      end

      def create
        @step = ImportDestination.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        params.require(:duty_calculator_steps_import_destination).permit(
          :import_destination,
        )
      end
    end
  end
end
