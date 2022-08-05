module Beta
  module Search
    class HitsCollection < SimpleDelegator
      delegate :new, to: :class

      def initialize(hits)
        @hits = hits.clone.presence || []

        super @hits
      end

      def by_heading(heading_id)
        new(select { |hit| hit.heading_id == heading_id })
      end
    end
  end
end
