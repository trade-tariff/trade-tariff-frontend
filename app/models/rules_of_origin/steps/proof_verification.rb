module RulesOfOrigin
  module Steps
    class ProofVerification < Base
      self.section = 'proofs'

      def skipped?
        true
      end

      def verification_text
        chosen_scheme.article('verification')&.content
      end
    end
  end
end
