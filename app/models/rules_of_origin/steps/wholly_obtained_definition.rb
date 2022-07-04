module RulesOfOrigin
  module Steps
    class WhollyObtainedDefinition < Base
      self.section = 'originating'

      def scheme_title
        chosen_scheme.title
      end

      def wholly_obtained_text
        chosen_scheme.article('wholly-obtained')&.content
      end

      def wholly_obtained_vessels_text
        chosen_scheme.article('wholly-obtained-vessels')&.content
      end
    end
  end
end
