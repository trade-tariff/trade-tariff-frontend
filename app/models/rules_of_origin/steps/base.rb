module RulesOfOrigin
  module Steps
    class Base < ::WizardSteps::Step
      delegate :rules_of_origin_schemes, to: :@wizard
      delegate :section, to: :class

      class << self
        attr_accessor :section
      end

      def service
        @store['service']
      end

      def service_country_name
        I18n.t "title.region_name.#{service}"
      end

      def trade_country_name
        @trade_country_name ||= GeographicalArea.find(@store['country_code'])
                                                .description
      end

      def commodity_code
        @store['commodity_code']
      end

      def chosen_scheme
        if @store['scheme_code']
          rules_of_origin_schemes.index_by(&:scheme_code)[@store['scheme_code']]
        else
          rules_of_origin_schemes.first
        end
      end

      def scheme_title
        chosen_scheme.title
      end

      def exporting?
        !chosen_scheme.unilateral && @store['import_or_export'] == 'export'
      end
    end
  end
end
