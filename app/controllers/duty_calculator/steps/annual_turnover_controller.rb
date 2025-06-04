module DutyCalculator
  module Steps
    class AnnualTurnoverController < BaseController
      def show
        @step = Steps::AnnualTurnover.new
      end

      def create
        @step = Steps::AnnualTurnover.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        params.require(:duty_calculator_steps_annual_turnover).permit(
          :annual_turnover,
        )
      end
    end
  end
end
