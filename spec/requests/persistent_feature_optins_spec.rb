require 'spec_helper'

RSpec.describe 'Persistent feature opt-ins', type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  before do
    stub_const('ENV', ENV.to_hash.merge('ENVIRONMENT' => 'production'))
    # Model the opt-in segment, not a direct feature override. The real Edge
    # HTTP contract and transient trait serialization are covered separately.
    allow(FlagsmithClient.instance).to receive(:get_flags_for) do |_identity, traits|
      enabled = traits.dig('interactive_search', :value) == true
      TestFlagsmithClient::TestFlags.new('interactive_search' => enabled)
    end
  end

  it 'retains the opt-in after session loss, then removes it', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    identity = cookies['flagsmith_anonymous_id']
    cookies.delete('_tradetarifffrontend_session')

    get '/find_commodity'
    expect(response).to have_http_status(:ok)
    expect(Capybara.string(response.body)).to have_link('AI-assisted search')
    expect(cookies['flagsmith_anonymous_id']).to eq(identity)

    get '/feature-flags'
    expect(response.body).to include('Saved preference: Opted in', 'Available now')

    patch '/feature-flags/interactive_search', params: { enabled: 'false' }
    cookies.delete('_tradetarifffrontend_session')
    get '/find_commodity'
    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
  end

  it 'does not transfer preferences to a new identity' do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    cookies.delete('flagsmith_anonymous_id')
    get '/find_commodity'

    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
  end

  it 'distinguishes saved opt-in from an operator-disabled feature', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    allow(FlagsmithClient.instance).to receive(:get_flags_for)
      .and_return(TestFlagsmithClient::TestFlags.new('interactive_search' => false))

    get '/feature-flags'
    expect(response.body).to include('Saved preference: Opted in', 'Not available now')
    expect(Capybara.string(response.body)).to have_button('Remove opt-in')
    get '/find_commodity'
    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
  end

  it 'keeps XI excluded despite a saved opt-in', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    get '/xi/feature-flags'
    expect(response.body).to include('Saved preference: Opted in', 'Not available now')
    get '/xi/find_commodity'
    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
  end

  it 'fails closed when persisted preferences cannot be read', :aggregate_failures do
    patch '/feature-flags/interactive_search', params: { enabled: 'true' }
    allow(FlagsmithManagementClient.instance).to receive(:get_traits_for).and_raise(Faraday::TimeoutError)

    get '/find_commodity'
    expect(response).to have_http_status(:ok)
    expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
    get '/feature-flags'
    expect(response.body).to include('Feature flags could not be loaded')
    expect(Capybara.string(response.body)).not_to have_button('Opt in')
  end
end
