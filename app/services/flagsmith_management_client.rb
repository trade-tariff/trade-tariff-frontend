# Reads and writes saved preferences through core. Edge evaluates request traits
# but does not retrieve these persisted preferences.
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

  # Identity-level transiency reads existing traits without creating an unknown
  # identity. An ordinary SDK GET or transient traits alone do not provide this.
  def get_traits_for(identity)
    response = @connection.post('/api/v1/identities/', {
      identifier: identity.identifier,
      transient: true,
      traits: [],
    })
    traits = response.body.fetch('traits')
    raise TypeError, 'Flagsmith traits must be an array' unless traits.is_a?(Array)

    traits.to_h { |trait| [trait.fetch('trait_key'), trait.fetch('trait_value')] }
  end

  # A null value on the bulk endpoint deletes the trait without creating an
  # unknown identity. The single-trait POST endpoint does not support deletion.
  def delete_trait(identifier, trait_key)
    @connection.put('/api/v1/traits/bulk/', [{
      identity: { identifier: },
      trait_key: trait_key.to_s,
      trait_value: nil,
    }])
  end

  # Set a trait on the given Flagsmith identity.
  # trait_value should be a boolean, string, integer, or float.
  # Raises Faraday::Error on non-2xx responses.
  def set_trait(identifier, trait_key, trait_value)
    @connection.post('/api/v1/traits/', {
      identity: { identifier: identifier },
      trait_key: trait_key.to_s,
      trait_value: trait_value,
    })
  end
end
