module RulesOfOrigin
  module Steps
    class PartsComponents < Base
      self.section = 'originating'

      def skipped?
        @store['wholly_obtained'] != 'no'
      end

      def scheme_details
        article = exporting? ? 'cumulation-export' : 'cumulation-import'
        chosen_scheme.article(article)&.content
      end

      def exporting?
        !chosen_scheme.unilateral && @store['import_or_export'] == 'export'
      end
    end
  end
end
