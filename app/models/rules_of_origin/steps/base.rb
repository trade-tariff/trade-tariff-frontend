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

      def country_name
        exporting? ? service_country_name : trade_country_name
      end

      def trade_direction_chosen?
        !trade_direction.nil?
      end

      def trade_direction
        return unless chosen_scheme.unilateral || @store['import_or_export'].present?

        exporting? ? 'export' : 'import'
      end

      def commodity_code
        @store['commodity_code']
      end

      def find_declarable
        @find_declarable ||= if commodity_code.match?(/\d{4}0{6}/)
                               Heading.find(commodity_code[0, 4])
                             else
                               Commodity.find(commodity_code)
                             end
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

      delegate :origin_reference_document, to: :chosen_scheme

      def exporting?
        !chosen_scheme.unilateral && @store['import_or_export'] == 'export'
      end

    private

      def only_wholly_obtained_rules?
        chosen_scheme.v2_rules.all?(&:only_wholly_obtained_class?)
      end
    end
  end
end
