# Singleton wrapper around the Flagsmith SDK client.
#
# Evaluation (get_flags_for) uses the SDK environment key to call the
# Flagsmith API and returns a Flagsmith::Flags::Collection.
#
# Mutations (enable_for_identity, disable_for_identity, etc.) use the
# Admin API key via a separate Faraday connection.
#
# In tests, FlagsmithClient.instance is replaced with a TestFlagsmithClient
# double (see spec/support/flagsmith.rb). Use FlagsmithClient.instance= to
# inject any replacement.
class FlagsmithClient
  class << self
    def instance
      @instance ||= new(
        environment_key: ENV.fetch('FLAGSMITH_ENVIRONMENT_KEY', nil),
        api_url: ENV.fetch('FLAGSMITH_API_URL', nil),
        admin_api_key: ENV.fetch('FLAGSMITH_ADMIN_API_KEY', nil),
      )
    end

    def instance=(client)
      @instance = client
    end
  end

  def initialize(environment_key:, api_url:, admin_api_key:)
    @environment_key = environment_key
    @api_url = api_url.to_s.delete_suffix('/')
    @admin_api_key = admin_api_key
    @sdk_client = Flagsmith::Client.new(
      environment_key: @environment_key,
      api_url: "#{@api_url}/",
      # Return a disabled default flag rather than raising for unknown features.
      default_flag_handler: ->(name) { Flagsmith::Flags::DefaultFlag.new(enabled: false, value: nil) },
    )
  end

  # Returns a Flagsmith::Flags::Collection for the given identity.
  # Call is_feature_enabled('flag_name') or get_feature_value('flag_name') on the result.
  # Unknown flags return false (via default_flag_handler) rather than raising.
  def get_flags_for(identity)
    @sdk_client.get_identity_flags(identity.identifier)
  end

  # Sets a per-identity flag override to enabled via the Admin API.
  def enable_for_identity(flag, identity)
    set_identity_flag_state(flag.to_s, identity, enabled: true)
  end

  # Sets a per-identity flag override to disabled via the Admin API.
  def disable_for_identity(flag, identity)
    set_identity_flag_state(flag.to_s, identity, enabled: false)
  end

  # Returns an array of flag names that are overridden to enabled for the given identifier.
  # Used during anonymous->authenticated migration to know which flags to copy.
  def get_identity_overrides(identifier)
    identity_pk = fetch_or_create_identity_pk(identifier)
    resp = admin_connection.get(
      "environments/#{@environment_key}/identities/#{identity_pk}/featurestates/",
    )
    resp.body.fetch('results', [])
        .select { |fs| fs['enabled'] }
        .map { |fs| fs.dig('feature', 'name') }
  end

  # Deletes an identity record from Flagsmith.
  # Called during anonymous->authenticated migration to clean up the anonymous identity.
  def delete_identity(identifier)
    results = admin_connection.get(
      "environments/#{@environment_key}/identities/",
      { q: identifier },
    ).body.fetch('results', [])
    return if results.empty?

    admin_connection.delete(
      "environments/#{@environment_key}/identities/#{results.first['id']}/",
    )
  end

  private

  # Two-step Admin API write: find (or create) the identity's numeric pk, then
  # either patch an existing feature state or create a new one for that identity.
  def set_identity_flag_state(flag_name, identity, enabled:)
    identity_pk = fetch_or_create_identity_pk(identity.identifier)
    write_feature_state(identity_pk, flag_name, enabled:)
  end

  def fetch_or_create_identity_pk(identifier)
    results = admin_connection.get(
      "environments/#{@environment_key}/identities/",
      { q: identifier },
    ).body.fetch('results', [])

    return results.first['id'] if results.any?

    admin_connection.post(
      "environments/#{@environment_key}/identities/",
    ) { |req| req.body = { identifier: }.to_json }.body['id']
  end

  def write_feature_state(identity_pk, flag_name, enabled:)
    featurestates_url = "environments/#{@environment_key}/identities/#{identity_pk}/featurestates/"
    existing = admin_connection.get(featurestates_url).body.fetch('results', []).find do |fs|
      fs.dig('feature', 'name') == flag_name
    end

    if existing
      admin_connection.patch("#{featurestates_url}#{existing['id']}/") do |req|
        req.body = { enabled: }.to_json
      end
    else
      feature_id = fetch_feature_id(flag_name)
      admin_connection.post(featurestates_url) do |req|
        req.body = { feature: feature_id, enabled: }.to_json
      end
    end
  end

  def fetch_feature_id(flag_name)
    admin_connection
      .get('features/featurestates/', { environment: @environment_key, feature__name: flag_name })
      .body.fetch('results', []).first&.dig('feature')
  end

  def admin_connection
    @admin_connection ||= Faraday.new(url: "#{@api_url}/") do |conn|
      conn.request :json
      conn.response :json
      conn.headers['Authorization'] = "Token #{@admin_api_key}"
      conn.adapter :net_http
    end
  end
end
