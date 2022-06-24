module RulesOfOrigin
  module Steps
    class WhollyObtainedDefinition < Base
      self.section = 'originating'

      def scheme_title
        chosen_scheme.title
      end
    end
  end
end
