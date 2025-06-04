module DutyCalculator
  module Steps
    class DocumentCodesController < BaseController
      def show
        @step = Steps::DocumentCode.new(permitted_params)
      end

      def create
        @step = Steps::DocumentCode.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        return params.permit(:measure_type_id) if params[:duty_calculator_steps_document_code].blank?

        params.require(:duty_calculator_steps_document_code).permit(
          :document_code_uk,
          :document_code_xi,
        ).merge(
          params.permit(:measure_type_id),
        )
      end
    end
  end
end
