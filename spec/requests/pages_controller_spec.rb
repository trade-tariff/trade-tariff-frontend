require 'spec_helper'

RSpec.describe PagesController, type: :request do
  subject { response }

  context 'when asked for XML file' do
    before { get opensearch_path(format: 'xml') }

    it { is_expected.to have_http_status(:ok) }

    it 'renders OpenSearch file successfully' do
      expect(response.body).to include 'Tariff'
    end
  end

  describe 'GET #privacy' do
    before { get privacy_path }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('pages/privacy') }
  end

  describe 'GET #help' do
    before { get help_path }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('pages/help') }
  end

  describe 'GET #cn2021_cn2022', vcr: { cassette_name: 'chapters' } do
    before { get cn2021_cn2022_path }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('pages/cn2021_cn2022') }

    it 'assigns chapters' do
      expect(assigns[:chapters]).to be_many
    end
  end
end
