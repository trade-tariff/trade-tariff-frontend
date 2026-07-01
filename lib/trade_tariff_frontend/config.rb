require_relative 'flagsmith_backed_config'

module TradeTariffFrontend
  module Config
    prepend FlagsmithBackedConfig

    def production?
      environment == 'production'
    end

    def environment
      ENV.fetch('ENVIRONMENT', 'production')
    end

    def id_token_cookie_name
      cookie_name_for('id_token')
    end

    def refresh_token_cookie_name
      cookie_name_for('refresh_token')
    end

    def cookie_name_for(base_name)
      case environment
      when 'production'
        base_name
      else
        "#{environment}_#{base_name}"
      end.to_sym
    end

    def redis_config
      { url: ENV['REDIS_URL'], db: 0, id: nil }
    end

    def from_email
      ENV['TARIFF_FROM_EMAIL']
    end

    def to_email
      ENV['TARIFF_TO_EMAIL']
    end

    def support_email
      ENV['TARIFF_SUPPORT_EMAIL'].presence || DEFAULT_SUPPORT_EMAIL
    end

    def enquiries_email
      DEFAULT_ENQUIRIES_EMAIL
    end

    def host
      ENV.fetch('FRONTEND_HOST', 'http://localhost')
    end

    def developer_portal_url
      ENV.fetch('DEVELOPER_PORTAL_URL') { "https://hub.#{base_domain}/" }
    end

    def flagsmith_api_url
      ENV['FLAGSMITH_API_URL'].presence || FLAGSMITH_API_URLS[environment]
    end

    def identity_base_url
      ENV.fetch('IDENTITY_BASE_URL', 'http://localhost:3005')
    end

    def identity_cookie_domain
      @identity_cookie_domain ||= if Rails.env.production?
                                    ".#{base_domain}"
                                  else
                                    :all
                                  end
    end

    def base_domain
      @base_domain ||= begin
        domain = ENV['GOVUK_APP_DOMAIN']

        unless /(http(s?):).*/.match(domain)
          domain = "https://#{domain}"
        end

        URI.parse(domain).host
      end
    end

    def backend_base_domain
      ENV['BACKEND_BASE_DOMAIN']
    end

    def check_duties_service_url
      ENV.fetch('CHECK_DUTIES_SERVICE_URL', 'https://www.check-duties-customs-exporting-goods.service.gov.uk')
    end

    def webchat_enabled?
      webchat_url.present?
    end

    def webchat_url
      configured_url = ENV['WEBCHAT_URL']
      return if configured_url.blank?
      return configured_url if configured_url.match?(%r{\Ahttps?://})

      URI.join(WEBCHAT_BASE_URL, configured_url).to_s
    end

    def legacy_results_to_show
      ENV.fetch('LEGACY_RESULTS_TO_SHOW', '5').to_i
    end

    def interactive_search_enabled?
      !production? && !ServiceChooser.xi?
    end

    def green_lanes_api_token
      "Bearer #{ENV['GREEN_LANES_API_TOKEN']}"
    end

    def google_tag_manager_container_id
      ENV.fetch('GOOGLE_TAG_MANAGER_CONTAINER_ID', '')
    end

    def waf_integration_url
      ENV['WAF_INTEGRATION_URL']
    end

    def waf_integration_enabled?
      waf_integration_url.present?
    end

    def basic_session_authentication?
      @basic_session_authentication ||= basic_session_password.present?
    end

    def basic_session_password
      @basic_session_password ||= ENV['BASIC_PASSWORD']
    end

    def basic_session_passwords
      @basic_session_passwords ||= basic_session_password.to_s.split(',').map(&:strip).reject(&:blank?)
    end

    flagsmith_flag :interactive_search_enabled?, name: :interactive_search, services: %i[uk]
    flagsmith_flag :webchat_enabled?, name: :webchat
  end
end
