module DutyCalculator
  module ServiceHelper
    include Rails.application.routes.url_helpers

    UK_SERVICE = 'uk'.freeze
    XI_SERVICE = 'xi'.freeze
    DEFAULT_REFERRED_SERVICE = UK_SERVICE.freeze

    def title
      t("title.#{referred_service}")
    end

    def header
      t("header.#{referred_service}")
    end

    def previous_service_url(commodity_code)
      UserSession.get&.redirect_to.presence || commodity_url(commodity_code)
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

    def xi_only_service_url_for(path)
      File.join(root_url, XI_SERVICE, path)
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
