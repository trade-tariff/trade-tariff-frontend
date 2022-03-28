# frozen_string_literal: true

require 'api_entity'

class NewsItem
  include ApiEntity

  CACHE_KEY = 'news-item-any-updates'
  CACHE_VERSION = 1
  CACHE_LIFETIME = 15.minutes

  DISPLAY_STYLE_REGULAR = 0

  collection_path '/news_items'

  attr_accessor :id, :title, :content, :display_style, :show_on_xi, :show_on_uk,
                :show_on_updates_page, :show_on_home_page, :show_on_banner

  attr_reader :start_date, :end_date

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

    def latest_for_banner
      collection(
        collection_path,
        service: service_name,
        target: 'banner',
        per_page: 1,
      ).first
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
      return false unless TradeTariffFrontend.news_items_enabled?

      Rails.cache.fetch(updates_cache_key, expires_in: CACHE_LIFETIME) do
        updates_page.any?
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
end
