module RulesOfOrigin
  module Steps
    class NotWhollyObtained < Base
      self.section = 'originating'

      def skipped?
        @store['wholly_obtained'] != 'no'
      end
    end
  end
end
