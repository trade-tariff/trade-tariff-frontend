require 'spec_helper'

describe PagesController, 'GET to #opensearch', type: :controller do
  context 'when asked for XML file' do
    render_views

    before do
      get :opensearch, format: 'xml'
    end

    it { is_expected.to respond_with(:success) }

    it 'renders OpenSearch file successfully' do
      expect(response.body).to include 'Tariff'
    end
  end

  context 'when asked with no format' do
    subject { get :opensearch }

    it 'does not raise ActionController::UnknownFormat' do
      expect(subject).to render_template('errors/not_found')
    end
  end

  context 'with unsupported format' do
    subject { get :opensearch, format: :json }

    it 'does not raise ActionController::UnknownFormat' do
      expect(subject).to render_template('errors/not_found')
    end
  end

  describe 'POST update_cookies' do
    subject(:response) { post :update_cookies, params: params }

    let(:remember_settings) { nil }
    let(:remember_usage) { nil }

    let(:params) do
      {
      }
    end

    it 'redirects to root path' do
      expect(response).to render_template(:cookies)
    end

    it 'does not update any cookies' do
      expect(response.cookies).to be_blank
    end

    context 'when remember settings is set to true' do
      let(:params) do
        {
          'cookie_remember_settings' => 'true',
        }
      end

      let(:expected_cookies_policy) do
        '{"settings":true,"remember_settings":"true"}'
      end

      it 'updates the policy cookie correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookies_policy)
      end
    end

    context 'when remember settings is set to false' do
      let(:params) do
        {
          'cookie_remember_settings' => 'false',
        }
      end

      let(:expected_cookies_policy) do
        '{"settings":true,"remember_settings":"false"}'
      end

      it 'updates the policy cookie correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookies_policy)
      end
    end

    context 'when remember usage is set to true' do
      let(:params) do
        {
          'cookie_consent_usage' => 'true',
        }
      end

      let(:expected_cookies_policy) do
        '{"settings":true,"usage":"true"}'
      end

      it 'updates the policy cookie correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookies_policy)
      end
    end

    context 'when remember usage is set to false' do
      let(:params) do
        {
          'cookie_consent_usage' => 'false',
        }
      end

      let(:expected_cookies_policy) do
        '{"settings":true,"usage":"false"}'
      end

      it 'updates the policy cookie correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookies_policy)
      end
    end
  end
end
