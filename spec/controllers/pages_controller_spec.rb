require 'spec_helper'

describe PagesController, type: :controller do
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
    subject(:search) { get :opensearch }

    it 'does not raise ActionController::UnknownFormat' do
      expect(search).to render_template('errors/not_found')
    end
  end

  context 'with unsupported format' do
    subject(:search) { get :opensearch, format: :json }

    it 'does not raise ActionController::UnknownFormat' do
      expect(search).to render_template('errors/not_found')
    end
  end

  describe 'GET #privacy' do
    subject(:response) { get :privacy }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('pages/privacy') }
  end

  describe 'GET #help' do
    subject(:response) { get :help }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('pages/help') }
  end
end
