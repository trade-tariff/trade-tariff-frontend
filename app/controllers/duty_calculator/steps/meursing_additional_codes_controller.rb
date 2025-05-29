module DutyCalculator
  module Steps
    class MeursingAdditionalCodesController < BaseController
      def show
        @step = Steps::MeursingAdditionalCode.new(meursing_additional_code_params)
      end

      def create
        @step = Steps::MeursingAdditionalCode.new(meursing_additional_code_params)

        validate(@step)
      end

      private

      def meursing_additional_code_params
        params.fetch(:duty_calculator_steps_meursing_additional_code, {}).permit(:meursing_additional_code)
      end
    end
  end
end
