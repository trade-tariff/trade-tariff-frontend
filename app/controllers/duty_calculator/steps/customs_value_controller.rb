module DutyCalculator
  module Steps
    class CustomsValueController < BaseController
      def show
        @step = Steps::CustomsValue.new
      end

      def create
        @step = Steps::CustomsValue.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        params.require(:duty_calculator_steps_customs_value).permit(
          :monetary_value,
          :shipping_cost,
          :insurance_cost,
        )
      end
    end
  end
end
