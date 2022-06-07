module RulesOfOrigin
  module Steps
    class Base < ::WizardSteps::Step
      def service_country_name
        I18n.t "title.region_name.#{@store['service']}"
      end

      def trade_country_name
        @trade_country_name ||= GeographicalArea.find(@store['country_code'])
                                                .description
      end

      def rules_of_origin_schemes
        @rules_of_origin_schemes =
          RulesOfOrigin::Scheme.all(@store['commodity_code'],
                                    @store['country_code'])
      end

      def chosen_scheme
        # FIXME: multiple scheme support coming in a later ticket
        rules_of_origin_schemes.first
      end
    end
  end
end
