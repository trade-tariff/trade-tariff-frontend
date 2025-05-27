module DutyCalculator
  module Steps
    class ExciseController < BaseController
      def show
        @step = Steps::Excise.new(permitted_params)
      end

      def create
        @step = Steps::Excise.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        return params.permit(:measure_type_id) if params[:duty_calculator_steps_excise].blank?

        params.require(:duty_calculator_steps_excise).permit(
          :additional_code,
        ).merge(params.permit(:measure_type_id))
      end
    end
  end
end
