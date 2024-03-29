module RulesOfOrigin
  module Steps
    class ProofsOfOrigin < Base
      self.section = 'proofs'

      delegate :proofs, to: :chosen_scheme

      def skipped?
        true
      end

      def duty_drawback_available?
        chosen_scheme.article('duty-drawback')&.content.present?
      end
    end
  end
end
