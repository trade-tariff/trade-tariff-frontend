module RulesOfOrigin
  module Steps
    class Originating < Base
      self.section = 'originating'

      def originating_country
        if @store['import_or_export'] == 'import'
          trade_country_name
        else
          I18n.t("import_destination.#{@store['service']}")
        end
      end
    end
  end
end
