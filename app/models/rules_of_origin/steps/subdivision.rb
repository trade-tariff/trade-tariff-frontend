module RulesOfOrigin
  module Steps
    class Subdivision < Base
      self.section = 'originating'

      delegate :description, to: :commodity, prefix: true

      attribute :subdivision
      validates :subdivision, inclusion: { in: :available_subdivisions }

      def skipped?
        @store['sufficient_processing'] == 'no'
      end

      def options
        chosen_scheme.rule_sets.select(&:subdivision)
      end

    private

      def commodity
        @commodity ||= Commodity.find(commodity_code)
      end

      def available_subdivisions
        options.map(&:resource_id)
      end
    end
  end
end
