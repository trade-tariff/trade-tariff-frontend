module DutyCalculator
  module Steps
    class FinalUseController < BaseController
      def show
        @step = Steps::FinalUse.new
      end

      def create
        @step = Steps::FinalUse.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        params.require(:steps_final_use).permit(
          :final_use,
        )
      end
    end
  end
end
