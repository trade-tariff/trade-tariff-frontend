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
        'cookie_remember_settings' => remember_settings,
        'cookie_consent_usage' => remember_usage,
      }
    end

    context 'when no cookie settings are specified' do
      it 'does not update any cookies' do
        expect(response.cookies).to be_blank
      end
    end

    context 'when remember settings is set to true' do
      let(:remember_settings) { true }

      let(:expected_cookies_policy) do
        '{"settings":true,"usage":false,"remember_settings":true}'
      end

      it 'updates the policy cookie correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookies_policy)
      end
    end

    context 'when remember usage is set to true' do
      let(:remember_usage) { true }

      let(:expected_cookies_policy) do
        '{"settings":true,"usage":true,"remember_settings":false}'
      end

      it 'updates the policy cookie correctly' do
        expect(response.cookies['cookies_policy']).to eq(expected_cookies_policy)
      end
    end
  end
end
