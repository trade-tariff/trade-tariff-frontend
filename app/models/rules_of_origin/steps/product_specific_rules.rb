module RulesOfOrigin
  module Steps
    class ProductSpecificRules < Base
      self.section = 'originating'

      delegate :description, to: :commodity, prefix: true

      def skipped?
        @store['sufficient_processing'] == 'no'
      end

      def options
        []
      end

    private

      def commodity
        @commodity ||= Commodity.find(commodity_code)
      end
    end
  end
end
