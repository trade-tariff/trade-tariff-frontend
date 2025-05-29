module DutyCalculator
  module Steps
    class CertificateOfOriginController < BaseController
      def show
        @step = Steps::CertificateOfOrigin.new
      end

      def create
        @step = Steps::CertificateOfOrigin.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        params.require(:duty_calculator_steps_certificate_of_origin).permit(
          :certificate_of_origin,
        )
      end
    end
  end
end
