require 'spec_helper'

RSpec.describe 'My OTT start page entry points', type: :request do
  include_context 'with cached chapters'

  let(:identity_url) { URI.join(TradeTariffFrontend.identity_base_url, '/myott').to_s }

  context 'when the user is not signed in' do
    subject(:page) { Capybara.string(response.body) }

    it 'shows the start page for a direct visit', :aggregate_failures do
      get '/subscriptions/start'

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('h1', text: 'Create and manage your tariff watch lists')
      expect(page).to have_link('Start now', href: identity_url)
      expect(page).to have_link('Continue', href: identity_url)
    end

    it 'shows the start page for the commodity page link', :aggregate_failures do
      get '/subscriptions'
      expect(response).to redirect_to('/subscriptions/start?return_to=%2Fsubscriptions')

      follow_redirect!
      expect(page).to have_link('Start now', href: identity_url)
    end

    it 'sends the stop press email link straight to sign in' do
      get '/subscriptions/?utm_source=private+beta&utm_medium=email&utm_campaign=stop+press+notification'
      follow_redirect!

      expect(response).to redirect_to("#{identity_url}?return_to=%2Fsubscriptions%3Futm_source%3Dprivate%2Bbeta%26utm_medium%3Demail%26utm_campaign%3Dstop%2Bpress%2Bnotification")
    end

    it 'sends the commodity watch list email link straight to sign in' do
      get '/subscriptions/mycommodities?as_of=2026-10-01'
      follow_redirect!

      expect(response).to redirect_to("#{identity_url}?return_to=%2Fsubscriptions%2Fmycommodities%3Fas_of%3D2026-10-01")
    end

    [
      'https://example.com/phishing',
      '//example.com/phishing',
      '/subscriptions.evil/mycommodities?as_of=2025-06-20',
    ].each do |unsafe_return_to|
      it "shows the start page without passing on the unsafe return URL #{unsafe_return_to}", :aggregate_failures do
        get '/subscriptions/start', params: { return_to: unsafe_return_to }

        expect(response).to have_http_status(:ok)
        expect(page).to have_link('Start now', href: identity_url)
        expect(page).to have_link('Continue', href: identity_url)
      end
    end
  end

  context 'when the user returns from sign in' do
    let(:subscription) { build(:subscription, :my_commodities) }
    let(:user) do
      build(:user, subscriptions: [
        { 'id' => subscription.resource_id, 'subscription_type' => 'my_commodities', 'active' => true },
      ])
    end

    before do
      allow(User).to receive(:find).and_return(user)
      allow(Subscription).to receive(:find).and_return(subscription)
      allow(TariffChanges::CommodityChange).to receive(:all).and_return([])
      allow(TariffChanges::GroupedMeasureChange).to receive(:all).and_return([])
      cookies[TradeTariffFrontend.id_token_cookie_name] = 'token'
    end

    it 'lands on the dated commodity watch list changes', :aggregate_failures do
      get '/subscriptions', params: { return_to: '/subscriptions/mycommodities?as_of=2026-10-01' }
      expect(response).to redirect_to('/subscriptions/mycommodities?as_of=2026-10-01')

      follow_redirect!
      expect(Capybara.string(response.body)).to have_content("Changes published: #{Date.new(2026, 10, 1).to_fs}")
    end
  end
end
