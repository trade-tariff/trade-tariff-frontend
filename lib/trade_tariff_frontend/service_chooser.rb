module TradeTariffFrontend
  module ServiceChooser
    SERVICE_CURRENCIES = {
      'uk' => 'GBP',
      'xi' => 'EUR',
    }.freeze

    module_function

    def with_source(service_source)
      original_service_source = service_choice

      self.service_choice = service_source.to_s

      result = yield

      self.service_choice = original_service_source

      result
    rescue StandardError => e
      # Restore the request's original service source
      self.service_choice = original_service_source

      raise e
    end

    def service_default
      ENV.fetch('SERVICE_DEFAULT', 'uk')
    end

    def currency
      SERVICE_CURRENCIES.fetch(service_choice, 'GBP')
    end

    def service_choices
      @service_choices ||= begin
        api_options = ENV.fetch('API_SERVICE_BACKEND_URL_OPTIONS', '{}')

        JSON.parse(api_options)
      end
    end

    def service_choice=(service_choice)
      Thread.current[:service_choice] = service_choice
    end

    def service_choice
      Thread.current[:service_choice]
    end

    def cache_with_service_choice(cache_key, options = {}, &block)
      Rails.cache.fetch("#{cache_prefix}.#{cache_key}", options, &block)
    end

    def xi_host
      service_choices['xi']
    end

    def uk_host
      service_choices['uk']
    end

    def api_client
      if xi?
        Rails.application.config.http_client_xi
      else
        Rails.application.config.http_client_uk
      end
    end

    def api_client_with_forwarding
      if xi?
        Rails.application.config.http_client_xi_forwarding
      else
        Rails.application.config.http_client_uk_forwarding
      end
    end

    def api_host
      host = service_choices[service_choice]

      return service_choices[service_default] if host.blank?

      host
    end

    def cache_prefix
      service_choice || service_default
    end

    def uk?
      (service_choice || service_default) == 'uk'
    end

    def xi?
      service_choice == 'xi'
    end
  end
end
