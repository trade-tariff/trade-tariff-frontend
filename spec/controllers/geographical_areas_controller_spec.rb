require 'spec_helper'

RSpec.describe GeographicalAreasController, type: :controller do
  describe 'GET show', vcr: { cassette_name: 'geographical_areas#1013' } do
    subject(:do_response) { get :show, params: { id: '1013' } }

    it { is_expected.to render_template('geographical_areas/show') }
    it { is_expected.to have_http_status(:success) }
  end

  describe 'GET show on XI service' do
    before { TradeTariffFrontend::ServiceChooser.service_choice = 'xi' }

    context 'when the geo area exists on XI', vcr: { cassette_name: 'geographical_areas_show_xi_1013' } do
      it 'renders successfully without falling back to UK' do
        get :show, params: { id: '1013' }

        expect(response).to have_http_status(:success)
      end
    end

    context 'when the geo area does not exist on XI but exists on UK', vcr: { cassette_name: 'geographical_areas_1400_xi_fallback' } do
      it 'renders successfully using UK data' do
        get :show, params: { id: '1400' }

        expect(response).to have_http_status(:success)
      end
    end

    context 'when the geo area does not exist on XI or UK', vcr: { cassette_name: 'geographical_areas_1400_not_found' } do
      it 'raises Faraday::ResourceNotFound' do
        expect { get :show, params: { id: '1400' } }.to raise_error(Faraday::ResourceNotFound)
      end
    end
  end
end
