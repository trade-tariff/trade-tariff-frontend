module RulesOfOrigin
  module Steps
    class SufficientProcessing < Base
      OPTIONS = %w[yes no].freeze

      self.section = 'originating'

      attribute :sufficient_processing
      validates :sufficient_processing, inclusion: { in: OPTIONS }

      def options
        OPTIONS
      end

      def insufficient_processing_text
        chosen_scheme.article('insufficient-processing')&.content
      end

      def skipped?
        @wizard.find('not_wholly_obtained').skipped?
      end
    end
  end
end
