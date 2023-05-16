module RulesOfOrigin
  module Steps
    class ProductSpecificRules < Base
      self.section = 'originating'

      attribute :rule
      validates :rule, inclusion: { in: :available_rules }

      def skipped?
        not_wholly_obtained_skipped? || insufficient_processing?
      end

      def options
        @options ||= rules + [none_option]
      end

      def rules
        use_subdivision_rules? ? subdivision_rules : non_subdivision_rules
      end

      def declarable_description
        find_declarable.description
      end

    private

      def none_option
        Struct.new(:resource_id, :rule, :footnotes)
              .new('none', none_option_text, [])
      end

      def none_option_text
        I18n.t "helpers.label.#{model_name.singular}.rule_options.none"
      end

      def available_rules
        options.map(&:resource_id)
      end

      def use_subdivision_rules?
        !(@wizard.find('subdivisions').skipped? || @store['subdivision_id'] == 'other')
      end

      def non_subdivision_rules
        chosen_scheme.rule_sets.reject(&:subdivision).flat_map(&:rules)
      end

      def subdivision_rules
        subdivision_rule_set.rules
      end

      def subdivision_rule_set
        chosen_scheme.rule_sets.find do |rs|
          rs.resource_id == @store['subdivision_id']
        end
      end

      def not_wholly_obtained_skipped?
        @wizard.find('not_wholly_obtained').skipped?
      end

      def insufficient_processing?
        @store['sufficient_processing'] == 'no'
      end
    end
  end
end
