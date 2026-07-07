class Search
  class GoodsNomenclatureMatch < BaseMatch
    BLANK_RESULT = Search::BlankResult.new(
      sections: [], chapters: [], headings: [], commodities: [],
    )

    array_attr_reader :sections, :chapters, :headings, :commodities
    array_attr_writer :sections, :chapters, :headings, :commodities

    def commodities=(commodity_data)
      @commodities = commodity_data.map do |cd|
        attributes = cd['_source']
        attributes['score'] = cd['_score'] if cd['_score'].present?

        Commodity.new(attributes)
      end

      self.commodity_headings = @commodities
    end

    def commodity_headings
      @commodity_headings.presence || []
    end

    # Extract Headings from Commodity object as we need to build
    # a tree for representation.
    # Also, add commodity to heading's commodity array so that they could
    # be listed in the tree.
    def commodity_headings=(commodities)
      @commodity_headings ||= []

      commodities.each do |commodity|
        if (existing_heading = find_heading(commodity.heading))
          existing_heading.add_commodity(commodity)
        else
          @commodity_headings << build_heading_from(commodity).tap do |heading|
            heading.add_commodity(commodity)
          end
        end
      end
    end

    def resulting_headings
      (headings + commodity_headings).sort_by(&:goods_nomenclature_item_id).uniq
    end

    def any?
      [headings, commodities, chapters, sections].any?(&:any?)
    end

    def all
      [headings, commodities, chapters, sections].flatten
    end

    delegate :size, to: :all

    private

    def find_heading(heading_for_search)
      return nil if heading_for_search.blank?

      (headings + commodity_headings).detect { |heading| heading == heading_for_search }
    end

    def build_heading_from(commodity)
      heading_attrs = commodity.respond_to?(:heading) && commodity.heading.present? ? commodity.heading.attributes : commodity.attributes
      chapter_attrs = commodity.respond_to?(:chapter) && commodity.chapter.present? ? commodity.chapter.attributes : {}
      section_attrs = commodity.respond_to?(:section) && commodity.section.present? ? commodity.section.attributes : {}

      Heading.new(heading_attrs.merge(chapter: chapter_attrs, section: section_attrs))
    end
  end
end
