module RulesOfOrigin
  module Steps
    class NotWhollyObtained < Base
      self.section = 'originating'

      def skipped?
        @store['wholly_obtained'] == 'yes' || only_wholly_obtained_rules?
      end
    end
  end
end
