module DutyCalculator
  module ServiceHelper
    UK_SERVICE = 'uk'.freeze
    XI_SERVICE = 'xi'.freeze

    DEFAULT_REFERRED_SERVICE = UK_SERVICE.freeze

    def title
      t("title.#{referred_service}")
    end

    def header
      t("header.#{referred_service}")
    end

    def sections_url
      service_url_for('/sections')
    end

    def search_url
      service_url_for('/find_commodity')
    end

    def browse_url
      service_url_for('/browse')
    end

    def a_to_z_url
      service_url_for('/a-z-index/a')
    end

    def tools_url
      service_url_for('/tools')
    end

    def news_url
      service_url_for('/news')
    end

    def help_url
      service_url_for('/help')
    end

    def previous_service_url(commodity_code)
      UserSession.get&.redirect_to.presence || commodity_url(commodity_code)
    end

    def commodity_url(commodity_code)
      service_url_for("/commodities/#{commodity_code}")
    end

    def feedback_url(choice = nil)
      if choice && %w[yes no].include?(choice)
        service_url_for("/feedback?page_useful=#{choice}")
      else
        service_url_for('/feedback')
      end
    end

    def trade_tariff_frontend_url
      @trade_tariff_frontend_url ||= Rails.configuration.trade_tariff_frontend_url
    end

    def meursing_lookup_url
      xi_only_service_url_for('/meursing_lookup/steps/start')
    end

    def referred_service
      ::TradeTariffFrontend::ServiceChooser.service_name
    end

    def google_tag_manager_container_id
      @google_tag_manager_container_id ||= ENV.fetch('GOOGLE_TAG_MANAGER_CONTAINER_ID', '')
    end

  private

    def service_url_for(path)
      return '#' if trade_tariff_frontend_url.blank?

      File.join(trade_tariff_frontend_url, referred_service_url, path)
    end

    def xi_only_service_url_for(path)
      return '#' if trade_tariff_frontend_url.blank?

      File.join(trade_tariff_frontend_url, XI_SERVICE, path)
    end

    def referred_service_url
      referred_service == UK_SERVICE ? '' : referred_service.to_s
    end

    def params_referred_service
      case params[:referred_service]
      when UK_SERVICE
        UK_SERVICE
      when XI_SERVICE
        XI_SERVICE
      end
    end

    def session_referred_service
      case ::TradeTariffFrontend::ServiceChooser.service_name
      when UK_SERVICE
        UK_SERVICE
      when XI_SERVICE
        XI_SERVICE
      end
    end
  end
end
