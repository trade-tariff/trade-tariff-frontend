module DutyCalculator
  module Steps
    class CertificateOfOrigin < Steps::Base
      OPTIONS = [
        OpenStruct.new(id: 'yes', name: 'Yes, I have a valid Certificate of Origin'),
        OpenStruct.new(id: 'no', name: 'No, I do not have a valid Certificate of Origin'),
      ].freeze

      STEPS_TO_REMOVE_FROM_SESSION = %w[document_code excise].freeze

      attribute :certificate_of_origin, :string

      validates :certificate_of_origin, presence: true

      def certificate_of_origin
        super || user_session.certificate_of_origin
      end

      def save!
        user_session.certificate_of_origin = certificate_of_origin
      end

      def next_step_path
        return duty_path if user_session.certificate_of_origin == 'yes'

        interstitial_path
      end

      def previous_step_path
        return planned_processing_path if user_session.unacceptable_processing?
        return final_use_path if user_session.final_use == 'no'

        trader_scheme_path if user_session.trader_scheme == 'no'
      end
    end
  end
end
