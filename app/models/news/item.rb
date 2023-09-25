require 'api_entity'

module News
  class Item
    include UkOnlyApiEntity

    DISPLAY_STYLE_REGULAR = 0

    set_collection_path '/news/items'

    attr_accessor :id,
                  :slug,
                  :title,
                  :precis,
                  :content,
                  :display_style,
                  :show_on_xi,
                  :show_on_uk,
                  :show_on_updates_page,
                  :show_on_home_page,
                  :show_on_banner

    attr_reader :start_date, :end_date

    has_many :collections, class_name: 'News::Collection'

    delegate :service_name, to: TradeTariffFrontend::ServiceChooser

    class << self
      delegate :service_name, to: TradeTariffFrontend::ServiceChooser, private: true

      def latest_for_home_page
        collection(
          collection_path,
          service: service_name,
          target: 'home',
          per_page: 1,
        ).first
      end

      def latest_banner
        collection(
          collection_path,
          service: service_name,
          target: 'banner',
          per_page: 1,
        ).first
      rescue Faraday::Error
        # This method is used by all pages in the main template so backend
        # failures should not prevent rendering of the frontend
        nil
      end

      def updates_page(**filters)
        if filters.key?(:story_year)
          filters = filters.merge(year: filters.delete(:story_year))
        end

        all filters.merge(service: service_name,
                          target: 'updates',
                          per_page: 10)
      end

      def for_feed
        collection(
          collection_path,
          target: 'updates',
        )
      end
    end

    def start_date=(date)
      @start_date = date.is_a?(String) ? Date.parse(date) : date
    end

    def end_date=(date)
      @end_date = date.is_a?(String) ? Date.parse(date) : date
    end

    def paragraphs
      @paragraphs ||= content.to_s.split(/(\r?\n)+/).map(&:presence).compact
    end

    def precis_with_fallback
      precis.presence || paragraphs.first
    end

    def content_after_precis?
      precis.present? ? content.present? : paragraphs.many?
    end

    def content_without_precis
      precis.present? ? content : paragraphs.slice(1..).join("\n\n")
    end

    def subheadings
      @subheadings ||= paragraphs.select { |p| p.start_with? '## ' }
                                 .map { |heading| heading.sub(/^\#\# /, '') }
    end

    def to_param
      slug.presence || id
    end
  end
end
