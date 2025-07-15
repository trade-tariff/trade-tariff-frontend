module DutyCalculator
  class ClientBuilder
    def initialize(service)
      @service = service
    end

    def call
      Uktt::Http.build(host)
    end

  private

    def host
      Rails.application.config.api_options[@service]
    end
  end
end
