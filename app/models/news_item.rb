require 'api_entity'

class NewsItem
  include ApiEntity

  DISPLAY_STYLE_REGULAR = 0

  collection_path '/news_items'

  attr_accessor :id, :title, :content, :display_style, :show_on_xi, :show_on_uk,
                :show_on_updates_page, :show_on_home_page

  attr_reader :start_date, :end_date

  class << self
    delegate :service_name, to: TradeTariffFrontend::ServiceChooser, private: true

    def latest_for_home_page
      collection("#{collection_path}/#{service_name}/home", per_page: 1).first
    end

    def updates_page(params = {})
      collection "#{collection_path}/#{service_name}/updates", params
    end

  private

    def api
      # Always use the UK backend because all News Items are stored there
      Rails.application.config.http_client_uk
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
