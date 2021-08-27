require 'spec_helper'

RSpec.describe Cookies::PoliciesController, type: :request do
  subject { response }

  describe 'GET #show' do
    before { get cookies_policy_path }

    it { is_expected.to have_http_status :success }
    it { is_expected.to have_attributes body: /Cookies on the UK Integrated Online Tariff/ }
  end

  describe 'POST #create' do
    describe 'with form submission' do
      before do
        post cookies_policy_path, params: {
          cookies_policy: {
            usage: 'true',
            remember_settings: 'false',
          },
        }
      end

      let(:expected_cookies) do
        {
          settings: true,
          usage: 'true',
          remember_settings: 'false',
        }.to_json
      end

      it 'sets the cookie policy correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookies)
      end

      it 'renders the form again' do
        expect(response).to have_http_status :success
      end

      it 'shows the saved message' do
        expect(response.body).to match('cookie settings were saved')
      end
    end

    describe 'with accept' do
      before do
        post cookies_policy_path, params: {
          cookies_policy: { acceptance: 'accept' },
        }
      end

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
      before do
        post cookies_policy_path, params: {
          cookies_policy: { acceptance: 'reject' },
        }
      end

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

    context 'without choosing options' do
      before { post cookies_policy_path }

      let(:expected_cookies) { { settings: true }.to_json }

      it 'sets the cookie policy correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookies)
      end

      it 'renders the form again' do
        expect(response).to have_http_status :success
      end

      it 'shows the saved message' do
        expect(response.body).to match('cookie settings were saved')
      end
    end
  end
end
