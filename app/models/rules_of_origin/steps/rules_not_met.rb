module RulesOfOrigin
  module Steps
    class RulesNotMet < Base
      self.section = 'originating'

      def skipped?
        @store['sufficient_processing'] != 'no'
      end

      def first_step
        @wizard.next_key('start')
      end
    end
  end
end
