module DutyCalculator
  module Steps
    class VatController < BaseController
      def show
        @vat_guidance_journeys = vat_guidance_journeys
        @vat_guidance_available = @vat_guidance_journeys.any?
        @vat_guidance_candidate = guided_vat_candidate
        @step = Steps::Vat.new(vat: @vat_guidance_candidate)
      end

      def create
        @step = Steps::Vat.new(permitted_params)

        validate(@step)
      end

      private

      def vat_guidance_journeys
        return [] unless Rails.env.development? || Rails.env.test? || ENV['VAT_GUIDANCE_DEMO_ENABLED'] == 'true'

        @vat_guidance_journeys ||= VatGuidancePrototype::ComposedJourneyRepository.new.for_commodity(user_session.commodity_code)
      rescue VatGuidancePrototype::ComposedJourneyRepository::InvalidArtifact,
             VatGuidancePrototype::ComposedJourneyRepository::JourneyNotFound,
             Faraday::Error,
             SystemCallError
        []
      end

      def guided_vat_candidate
        guidance_session = session[VatGuidanceController::SESSION_KEY]
        return unless guidance_session&.fetch('journey_id', nil) == user_session.commodity_code

        candidate = guidance_session['candidate_vat']
        candidate if vat_guidance_journeys.any? && applicable_vat_options.key?(candidate)
      end

      def permitted_params
        params.require(:duty_calculator_steps_vat).permit(
          :vat,
        )
      end
    end
  end
end
