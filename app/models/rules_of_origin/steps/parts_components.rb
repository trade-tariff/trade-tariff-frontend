module RulesOfOrigin
  module Steps
    class PartsComponents < Base
      self.section = 'originating'

      def skipped?
        @store['wholly_obtained'] != 'no'
      end

      def scheme_details
        'FIXME:'
      end
    end
  end
end
