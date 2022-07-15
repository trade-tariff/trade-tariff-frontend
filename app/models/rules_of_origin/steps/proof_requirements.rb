module RulesOfOrigin
  module Steps
    class ProofRequirements < Base
      self.section = 'proofs'

      def skipped?
        @store['wholly_obtained'] == 'no'
      end

      def processes_text
        chosen_scheme.article('origin_processes')&.content
      end
    end
  end
end
