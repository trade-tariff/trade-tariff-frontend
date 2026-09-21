# Reads and writes persisted manual preferences through the Flagsmith core API.
# Edge evaluates flags but does not retrieve these persisted identity traits.
class FlagsmithManagementClient
  CORE_API_URL = 'http://flagsmith.tariff.internal:8000'.freeze

  class << self
    def instance
      @instance || raise('FlagsmithManagementClient not configured')
    end

    attr_writer :instance

    def configured?
      @instance.present?
    end

    def configure(environment_key:)
      @instance = new(environment_key:)
    end
  end

  def initialize(environment_key:)
    @connection = Faraday.new(url: CORE_API_URL) do |f|
      f.request :json
      f.response :raise_error
      f.response :json
      f.options.timeout = 2
      f.headers['X-Environment-Key'] = environment_key
    end
  end

  # The SDK identity endpoint returns persisted traits without changing them.
  # It also creates an identity if this browser has not been seen by core yet.
  def get_traits_for(identity)
    response = @connection.post('/api/v1/identities/', {
      identifier: identity.identifier,
      traits: [],
    })
    response.body.fetch('traits').to_h { |trait| [trait.fetch('trait_key'), trait.fetch('trait_value')] }
  end

  def set_trait(identifier, trait_key, trait_value)
    @connection.post('/api/v1/traits/', {
      identity: { identifier: identifier },
      trait_key: trait_key.to_s,
      trait_value: trait_value,
    })
  end
end
