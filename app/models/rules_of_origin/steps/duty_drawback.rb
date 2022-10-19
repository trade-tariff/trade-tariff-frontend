module RulesOfOrigin
  module Steps
    class DutyDrawback < Base
      self.section = 'proofs'

      def skipped?
        true
      end

      def duty_drawback_text
        chosen_scheme.article('duty-drawback')&.content
      end
    end
  end
end
