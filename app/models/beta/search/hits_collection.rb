module Beta
  module Search
    class HitsCollection < SimpleDelegator
      delegate :new, to: :class

      def initialize(hits)
        @hits = hits.clone.presence || []

        super @hits
      end

      def commodities
        new(select { |hit| hit.is_a?(Commodity) })
      end
    end
  end
end
