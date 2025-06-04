module DutyCalculator
  module Steps
    class VatController < BaseController
      def show
        @step = Steps::Vat.new
      end

      def create
        @step = Steps::Vat.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        params.require(:duty_calculator_steps_vat).permit(
          :vat,
        )
      end
    end
  end
end
