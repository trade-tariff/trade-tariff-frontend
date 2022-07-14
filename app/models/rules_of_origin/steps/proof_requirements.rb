module RulesOfOrigin
  module Steps
    class ProofRequirements < Base
      self.section = 'proofs'

      def skipped?
        @store['wholly_obtained'] == 'no'
      end
    end
  end
end
