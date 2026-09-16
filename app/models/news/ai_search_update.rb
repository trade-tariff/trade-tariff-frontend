module News
  class AiSearchUpdate
    START_DATE = Date.new(2026, 9, 9)
    COLLECTION_SLUG = 'service_updates'.freeze

    def ai_search_update?
      true
    end

    def start_date
      START_DATE
    end

    def self.merge(news_items, enabled:, year: nil, collection: nil, collection_id: nil, page: nil, previous_oldest: nil)
      items = news_items.to_a
      return items unless visible?(enabled:, year:, collection:, collection_id:)

      insert(
        items,
        page: normalized_page(page),
        last_page: last_page?(news_items, page),
        previous_oldest:,
      )
    end

    def self.visible?(enabled:, year:, collection:, collection_id:)
      return false unless enabled
      return false if year.present? && year.to_i != START_DATE.year
      return true if collection_id.blank?

      collection&.slug == COLLECTION_SLUG
    end
    private_class_method :visible?

    def self.insert(items, page:, last_page:, previous_oldest:)
      return page == 1 ? [new] : items if items.empty?
      return items unless belongs_on_page?(items, page:, last_page:, previous_oldest:)

      items.dup.insert(insertion_index(items, START_DATE), new)
    end
    private_class_method :insert

    def self.belongs_on_page?(items, page:, last_page:, previous_oldest:)
      date = START_DATE
      newest = items.first.start_date&.to_date
      oldest = items.last.start_date&.to_date
      return false if newest.blank? || oldest.blank?

      (date <= newest && date >= oldest) ||
        (page == 1 && date >= newest) ||
        (last_page && date <= oldest) ||
        first_older_page?(page:, date:, newest:, previous_oldest:)
    end
    private_class_method :belongs_on_page?

    def self.first_older_page?(page:, date:, newest:, previous_oldest:)
      page > 1 &&
        date > newest &&
        previous_oldest.present? &&
        previous_oldest.to_date > date
    end
    private_class_method :first_older_page?

    def self.insertion_index(items, date)
      items.index { |item| item.start_date.present? && item.start_date.to_date <= date } || items.length
    end
    private_class_method :insertion_index

    def self.normalized_page(page)
      page.to_i < 1 ? 1 : page.to_i
    end
    private_class_method :normalized_page

    def self.last_page?(news_items, page)
      page_number = normalized_page(page)

      if news_items.respond_to?(:total_pages)
        page_number >= news_items.total_pages
      else
        true
      end
    end
    private_class_method :last_page?
  end
end
