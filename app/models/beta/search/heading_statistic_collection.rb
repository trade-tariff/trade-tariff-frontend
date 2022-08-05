module Beta
  module Search
    class HeadingStatisticCollection < SimpleDelegator
      delegate :new, to: :class

      def initialize(heading_statistics)
        @heading_statistics = heading_statistics.clone.presence || []

        super @heading_statistics
      end

      def by_chapter(chapter_id)
        new(select { |hit| hit.chapter_id == chapter_id })
      end
    end
  end
end
