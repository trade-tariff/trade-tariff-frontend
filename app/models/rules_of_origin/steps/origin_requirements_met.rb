module RulesOfOrigin
  module Steps
    class OriginRequirementsMet < Base
      self.section = 'proofs'

      def skipped?
        @store['wholly_obtained'] == 'no'
      end
    end
  end
end
