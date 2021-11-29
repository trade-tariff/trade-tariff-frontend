require 'spec_helper'

RSpec.describe TradingPartnersController, type: :controller do
  describe 'GET #show' do
    subject(:response) { get :show, params: query_params }

    context 'when there is no country in the query params' do
      let(:query_params) { {} }

      it 'initializes with the correct country' do
        response

        expect(assigns(:trading_partner).country).to eq(nil)
      end

      it 'attaches no error message' do
        response

        expect(assigns(:trading_partner).errors).to be_empty
      end

      it { is_expected.to render_template('trading_partners/show') }
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when there is a country in the query params' do
      let(:query_params) { { country: 'IT' } }

      it 'initializes with the correct country' do
        response

        expect(assigns(:trading_partner).country).to eq('IT')
      end

      it 'attaches no error message' do
        response

        expect(assigns(:trading_partner).errors).to be_empty
      end

      it { is_expected.to render_template('trading_partners/show') }
      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'PATCH #update', vcr: { cassette_name: 'geographical_areas#countries' } do
    subject(:response) { patch :update, params: trading_partner_params }

    context 'when passing valid change date params' do
      let(:trading_partner_params) { { trading_partner: { country: 'IT' } } }

      shared_examples_for 'a valid trading partner redirect' do |path_method, goods_nomenclature_code|
        before do
          session[:goods_nomenclature_code] = goods_nomenclature_code
        end

        it { is_expected.to redirect_to(public_send(path_method, country: 'IT', id: goods_nomenclature_code)) }
      end

      it_behaves_like 'a valid trading partner redirect', :sections_path, nil
      it_behaves_like 'a valid trading partner redirect', :chapter_path, '01'
      it_behaves_like 'a valid trading partner redirect', :heading_path, '1501'
      it_behaves_like 'a valid trading partner redirect', :commodity_path, '2402201000'
    end

    context 'when passing invalid change date params' do
      let(:trading_partner_params) { { trading_partner: { country: 'FOO' } } }

      it 'attaches the correct error message' do
        response

        expect(assigns(:trading_partner).errors.messages[:country]).to eq(['Select a valid trading partner'])
      end

      it { is_expected.to render_template('trading_partners/show') }
      it { is_expected.to have_http_status(:ok) }
    end
  end
end
