module RulesOfOrigin
  module Steps
    class NonAlterationRule < Base
      self.section = 'proofs'

      def skipped?
        true
      end

      def non_alteration_text
        chosen_scheme.article('non-alteration')&.content
      end
    end
  end
end
