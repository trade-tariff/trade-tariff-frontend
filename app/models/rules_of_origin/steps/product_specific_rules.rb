module RulesOfOrigin
  module Steps
    class ProductSpecificRules < Base
      self.section = 'originating'

      delegate :description, to: :commodity, prefix: true

      attribute :rule
      validates :rule, inclusion: { in: :available_rules }

      def skipped?
        @store['sufficient_processing'] == 'no'
      end

      def options
        @options ||= chosen_scheme.v2_rules + [none_option]
      end

    private

      def commodity
        @commodity ||= Commodity.find(commodity_code)
      end

      def none_option
        Struct.new(:resource_id, :rule).new('none', none_option_text)
      end

      def none_option_text
        I18n.t "helpers.label.#{model_name.singular}.rule_options.none"
      end

      def available_rules
        options.map(&:resource_id)
      end
    end
  end
end
