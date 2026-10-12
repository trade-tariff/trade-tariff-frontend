require 'spec_helper'

RSpec.describe 'Persistent feature opt-ins', type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  let(:preference_cookie) { Flagsmith::OptInPreferences::COOKIE_NAME.to_s }
  let(:session_cookie) { Rails.application.config.session_options.fetch(:key) }
  let(:identity_cookie) { 'flagsmith_anonymous_id' }
  let(:browser_id) { '8f9d312c-d30b-4b2e-a85d-6859b09471db' }

  before do
    stub_const('ENV', ENV.to_hash.merge('ENVIRONMENT' => 'production', 'INTERACTIVE_SEARCH' => ''))
    # Model an opt-in segment. Actual SDK serialization is covered by client specs.
    allow(FlagsmithClient.instance).to receive(:get_flags_for) do |_identity, traits|
      enabled = traits.dig('interactive_search', :value) == true
      TestFlagsmithClient::TestFlags.new('interactive_search' => enabled)
    end
    allow(FlagsmithManagementClient.instance).to receive(:get_traits_for).and_call_original
  end

  def cookie_jar
    ActionDispatch::Request.new(Rails.application.env_config.dup).cookie_jar
  end

  def saved_preferences
    jar = cookie_jar
    jar[preference_cookie] = cookies[preference_cookie]
    jar.signed[preference_cookie].fetch('preferences')
  end

  def set_legacy_preferences(traits)
    jar = cookie_jar
    jar.encrypted[session_cookie] = {
      value: { session_id: SecureRandom.hex(16), flagsmith_optin_traits: traits, unrelated: 'keep me' },
    }
    cookies[session_cookie] = jar[session_cookie]
  end

  it 'keeps an opt-in after session loss', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    identity = cookies[identity_cookie]
    cookies.delete(session_cookie)

    get '/find_commodity'

    expect(response).to have_http_status(:ok)
    expect(Capybara.string(response.body)).to have_link('AI-assisted search')
    expect(cookies[identity_cookie]).to eq(identity)
    expect(session[:flagsmith_optin_traits]).to be_nil
    expect(FlagsmithManagementClient.instance).not_to have_received(:get_traits_for)
    expect(Array(response.headers['Set-Cookie']).join).not_to include("#{preference_cookie}=")
  end

  it 'migrates true and false then cleans up', :aggregate_failures do
    cookies[identity_cookie] = browser_id
    set_legacy_preferences(interactive_search: true, parcel_gift_journey: false, webchat: true)

    get '/find_commodity'

    expect(saved_preferences).to eq('interactive_search' => true, 'parcel_gift_journey' => false)
    expect(session[:flagsmith_optin_traits]).to be_nil
    expect(session[:unrelated]).to eq('keep me')
    expect(cookies[identity_cookie]).to eq(browser_id)
    expect(Capybara.string(response.body)).to have_link('AI-assisted search')
    expect(FlagsmithManagementClient.instance).not_to have_received(:get_traits_for)

    cookies.delete(session_cookie)
    get '/find_commodity'
    expect(Capybara.string(response.body)).to have_link('AI-assisted search')
  end

  it 'does not restore stale session values', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'false' }
    set_legacy_preferences(interactive_search: true, parcel_gift_journey: false)

    get '/find_commodity'

    expect(saved_preferences).to eq('interactive_search' => false, 'parcel_gift_journey' => false)
    expect(session[:flagsmith_optin_traits]).to be_nil
    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
  end

  it 'does not transfer to a new identity', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    cookies.delete(identity_cookie)
    set_legacy_preferences(interactive_search: true)

    get '/find_commodity'

    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
    expect(saved_preferences).to eq({})
    expect(session[:flagsmith_optin_traits]).to be_nil
    expect(FlagsmithManagementClient.instance).not_to have_received(:get_traits_for)
  end

  it 'does not trust an altered cookie' do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    cookies[preference_cookie] = "#{cookies[preference_cookie]}tampered"

    get '/find_commodity'

    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
  end

  it 'does not reuse another environment' do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    stub_const('ENV', ENV.to_hash.merge('ENVIRONMENT' => 'staging'))

    get '/find_commodity'

    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
  end

  it 'renews both cookies with one expiry', :aggregate_failures do
    cookies[identity_cookie] = browser_id
    travel_to(Time.utc(2026, 10, 12, 12)) do
      patch '/feature-flags/interactive_search', params: { enabled: 'true' }

      headers = Array(response.headers['Set-Cookie'])
      preference = headers.find { |header| header.start_with?("#{preference_cookie}=") }
      identity = headers.find { |header| header.start_with?("#{identity_cookie}=") }
      expect(preference).to include('expires=Tue, 12 Oct 2027 12:00:00 GMT', 'httponly', 'samesite=lax')
      expect(identity).to include('expires=Tue, 12 Oct 2027 12:00:00 GMT')
      expect(cookies[identity_cookie]).to eq(browser_id)
    end
  end

  it 'recovers core-only preferences on settings', :aggregate_failures do
    cookies[identity_cookie] = browser_id
    FlagsmithManagementClient.instance.set_trait("Anonymous:#{browser_id}", 'interactive_search', true)

    get '/feature-flags'

    expect(response.body).to include('Saved preference: Opted in', 'Available now')
    expect(saved_preferences).to eq('interactive_search' => true)

    cookies.delete(session_cookie)
    get '/find_commodity'
    expect(Capybara.string(response.body)).to have_link('AI-assisted search')
    expect(FlagsmithManagementClient.instance).to have_received(:get_traits_for).once
  end

  it 'refreshes core changes on settings', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    FlagsmithManagementClient.instance.set_trait("Anonymous:#{cookies[identity_cookie]}", 'interactive_search', false)

    get '/feature-flags'

    expect(response.body).to include('Saved preference: Not opted in', 'Not available now')
    expect(saved_preferences).to eq('interactive_search' => false)
    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
  end

  it 'retains preferences on refresh failure', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    original_cookie = cookies[preference_cookie]
    allow(FlagsmithManagementClient.instance).to receive(:get_traits_for).and_raise(Faraday::TimeoutError)

    get '/feature-flags'

    expect(response.body).to include('Feature flags could not be loaded')
    expect(response.body).not_to include('No features are currently available for opt-in')
    expect(cookies[preference_cookie]).to eq(original_cookie)
    expect(Capybara.string(response.body)).not_to have_button('Opt in')

    get '/find_commodity'
    expect(Capybara.string(response.body)).to have_link('AI-assisted search')
  end

  it 'retains preferences on save failure', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    original_cookie = cookies[preference_cookie]
    allow(FlagsmithManagementClient.instance).to receive(:set_trait).and_raise(Faraday::TimeoutError)

    patch '/feature-flags/interactive_search', params: { enabled: 'false' }
    get '/find_commodity'

    expect(cookies[preference_cookie]).to eq(original_cookie)
    expect(Capybara.string(response.body)).to have_link('AI-assisted search')
  end

  it 'keeps ordinary cookie-less traffic off core', :aggregate_failures do
    3.times do
      cookies.to_hash.each_key { |name| cookies.delete(name) }
      get '/find_commodity'
      expect(response).to have_http_status(:ok)
      expect(cookies[preference_cookie]).to be_nil
    end

    expect(FlagsmithManagementClient.instance).not_to have_received(:get_traits_for)
    expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to be_empty
  end

  it 'keeps XI excluded despite an opt-in', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }

    get '/xi/feature-flags'

    expect(response.body).to include('Saved preference: Opted in', 'Not available now')
    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
  end
end
