module DutyCalculator
  class ClientBuilder
    DEFAULT_VERSION = 'v2'.freeze
    DEFAULT_FORMAT = 'jsonapi'.freeze

    def initialize(service)
      @service = service
    end

    def call
      Uktt::Http.build(
        host,
        DEFAULT_VERSION,
        DEFAULT_FORMAT,
      )
    end

  private

    def host
      Rails.application.config.api_options[@service]
    end
  end
end
