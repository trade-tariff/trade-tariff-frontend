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
end
