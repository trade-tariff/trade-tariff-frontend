require 'api_entity'

class NewsItem
  include ApiEntity

  CACHE_KEY = 'news-item-any-updates'.freeze
  BANNER_CACHE_KEY = 'news-item-latest-banner'.freeze
  CACHE_VERSION = 3
  CACHE_LIFETIME = 15.minutes
  BANNER_CACHE_LIFETIME = 5.minutes

  DISPLAY_STYLE_REGULAR = 0

  collection_path '/news_items'

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

  has_many :collections, class_name: 'NewsCollection'

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

    def updates_page
      collection(
        collection_path,
        service: service_name,
        target: 'updates',
      )
    end

    def for_feed
      collection(
        collection_path,
        target: 'updates',
      )
    end

    def any_updates?
      Rails.cache.fetch(updates_cache_key, expires_in: CACHE_LIFETIME) do
        updates_page.any?
      rescue Faraday::Error
        # This method is used by all pages in the main template so backend
        # failures should not prevent rendering of the frontend
        false
      end
    end

    def cached_latest_banner
      Rails.cache.fetch(banner_cache_key, expires_in: BANNER_CACHE_LIFETIME) do
        latest_banner
      end
    end

  private

    def api
      # Always use the UK backend because all News Items are stored there
      Rails.application.config.http_client_uk
    end

    def updates_cache_key
      "#{CACHE_KEY}-#{service_name}-v#{CACHE_VERSION}"
    end

    def banner_cache_key
      "#{BANNER_CACHE_KEY}-#{service_name}-v#{CACHE_VERSION}"
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
end
