module RulesOfOrigin
  module Steps
    class ComponentsDefinition < Base
      self.section = 'originating'

      def neutral_elements_text
        chosen_scheme.article('neutral-elements')&.content
      end

      def packaging_text
        chosen_scheme.article('packaging')&.content
      end

      def packaging_retail_text
        chosen_scheme.article('packaging_retail')&.content
      end

      def accessories_text
        chosen_scheme.article('accessories')&.content
      end
    end
  end
end
