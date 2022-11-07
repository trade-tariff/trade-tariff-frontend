module RulesOfOrigin
  module Steps
    class OriginRequirementsMet < Base
      self.section = 'proofs'

      def skipped?
        not_wholly_obtained? && (psr_skipped? || rules_not_met?)
      end

      def duty_drawback_available?
        !!chosen_scheme.article('duty-drawback')&.content&.present?
      end

      def non_alteration_available?
        !!chosen_scheme.article('non-alteration')&.content&.present?
      end

    private

      def not_wholly_obtained?
        @store['wholly_obtained'] == 'no'
      end

      def psr_skipped?
        @wizard.find('product_specific_rules').skipped?
      end

      def rules_not_met?
        @store['rule'].blank? || @store['rule'] == 'none'
      end
    end
  end
end
