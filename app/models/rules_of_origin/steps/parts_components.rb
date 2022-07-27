module RulesOfOrigin
  module Steps
    class PartsComponents < Base
      self.section = 'originating'

      def skipped?
        @wizard.find('not_wholly_obtained').skipped?
      end

      def scheme_details
        article = exporting? ? 'cumulation-export' : 'cumulation-import'
        chosen_scheme.article(article)&.content
      end
    end
  end
end
