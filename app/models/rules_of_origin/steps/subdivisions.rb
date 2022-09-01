module RulesOfOrigin
  module Steps
    class Subdivisions < Base
      self.section = 'originating'

      attribute :subdivision_id
      validates :subdivision_id, inclusion: { in: :available_subdivisions }

      def skipped?
        not_wholly_obtained_skipped? || insufficient_processing? || options.none?
      end

      def options
        subdivided = rule_sets_with_subdivisions

        if subdivided.none?
          []
        elsif rule_sets_without_subdivisions.any?
          subdivided + [other_option]
        else
          subdivided
        end
      end

      def declarable_description
        find_declarable.description
      end

    private

      def rule_sets_with_subdivisions
        chosen_scheme.rule_sets.select(&:subdivision)
      end

      def rule_sets_without_subdivisions
        chosen_scheme.rule_sets.reject(&:subdivision)
      end

      def commodity
        @commodity ||= Commodity.find(commodity_code)
      end

      def available_subdivisions
        options.map(&:resource_id)
      end

      def not_wholly_obtained_skipped?
        @wizard.find('not_wholly_obtained').skipped?
      end

      def insufficient_processing?
        @store['sufficient_processing'] == 'no'
      end

      def other_option
        Struct.new(:resource_id, :subdivision).new('other', other_option_text)
      end

      def other_option_text
        I18n.t "helpers.label.#{model_name.singular}.subdivision_id_options.other"
      end
    end
  end
end
