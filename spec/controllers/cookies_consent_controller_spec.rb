require 'spec_helper'

RSpec.describe CookiesConsentController, type: :controller do
  describe 'POST create' do
    subject(:response) { post :create, params: { cookie_acceptance: acceptance } }

    describe 'with accept' do
      let(:acceptance) { 'accept' }

      let(:expected_cookies) do
        {
          settings: true,
          usage: 'true',
          remember_settings: 'true',
        }.to_json
      end

      it 'sets the cookie policy correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookies)
      end

      it 'redirects to the correct fallback location' do
        expect(response).to redirect_to(sections_path)
      end
    end

    describe 'with reject' do
      let(:acceptance) { 'reject' }

      let(:expected_cookie) do
        {
          settings: true,
          usage: 'false',
          remember_settings: 'false',
        }.to_json
      end

      it 'sets the cookie policy correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookie)
      end

      it 'redirects to the correct fallback location' do
        expect(response).to redirect_to(sections_path)
      end
    end
  end

  describe 'POST add_seen_confirmation_message' do
    subject(:response) { post :add_seen_confirmation_message }

    it 'sets the cookie preference correctly' do
      expect(response.cookies['cookies_preferences_set']).to eq('true')
    end

    it 'redirects to the correct fallback location' do
      expect(response).to redirect_to(sections_path)
    end
  end
end
