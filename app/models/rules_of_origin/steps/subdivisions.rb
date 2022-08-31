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
        chosen_scheme.rule_sets.select(&:subdivision)
      end

      def declarable_description
        find_declarable.description
      end

    private

      def available_subdivisions
        options.map(&:resource_id)
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
