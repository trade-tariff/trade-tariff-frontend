module RulesOfOrigin
  module Steps
    class Tolerances < Base
      self.section = 'originating'

      def skipped?
        true
      end

      def tolerances_text
        chosen_scheme.article('tolerances')&.content
      end
    end
  end
end
