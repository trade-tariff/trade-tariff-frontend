module RulesOfOrigin
  module Steps
    class NotWhollyObtained < Base
      self.section = 'originating'

      def skipped?
        @store['wholly_obtained'] == 'yes' || single_wholly_obtained_rule?
      end
    end
  end
end
