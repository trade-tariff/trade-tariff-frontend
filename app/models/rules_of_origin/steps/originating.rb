module RulesOfOrigin
  module Steps
    class Originating < Base
      def originating_country
        if @store['import_or_export'] == 'import'
          trade_country_name
        else
          I18n.t("import_destination.#{@store['service']}")
        end
      end

      def scheme_title
        chosen_scheme.title
      end
    end
  end
end
