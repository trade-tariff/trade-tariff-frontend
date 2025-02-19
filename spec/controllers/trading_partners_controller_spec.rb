require 'spec_helper'

RSpec.describe TradingPartnersController, type: :controller do
  describe 'GET #show' do
    subject(:response) { get :show, params: }

    context 'when there is no country in the query params' do
      let(:params) { {} }

      it 'initializes with the correct country' do
        response

        expect(assigns(:trading_partner).country).to be_nil
      end

      it 'attaches no error message' do
        response

        expect(assigns(:trading_partner).errors).to be_empty
      end

      it { is_expected.to render_template('trading_partners/show') }
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when there is a country in the query params' do
      let(:params) { { country: 'IT' } }

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
    subject(:response) { patch :update, params: }

    shared_examples_for 'a valid trading partner redirect' do |path_method, goods_nomenclature_code|
      let(:params) { { trading_partner: { country: 'IT', anchor: 'export', goods_nomenclature_code: } } }

      it { is_expected.to redirect_to(public_send(path_method, country: 'IT', id: goods_nomenclature_code, anchor: 'export')) }
    end

    shared_examples_for 'an invalid trading partner redirect' do |path_method, goods_nomenclature_code|
      let(:params) { default_params.merge({ trading_partner: { country: 'FOO', anchor: 'export', goods_nomenclature_code: } }) }

      it { is_expected.to redirect_to(public_send(path_method, id: goods_nomenclature_code)) }
    end

    context 'when passing valid trading partner params' do
      it_behaves_like 'a valid trading partner redirect', :find_commodity_path, nil
      it_behaves_like 'a valid trading partner redirect', :chapter_path, '01'
      it_behaves_like 'a valid trading partner redirect', :heading_path, '1501'
      it_behaves_like 'a valid trading partner redirect', :commodity_path, '2402201000'
    end

    context 'when passing invalid trading partner params' do
      context 'when rendering errors is `true`' do
        let(:params) { { trading_partner: { country: 'FOO' }, render_errors: true } }

        it 'attaches the correct error message' do
          response

          expect(assigns(:trading_partner).errors.messages[:country]).to eq(['Select a country'])
        end

        it { is_expected.to render_template('trading_partners/show') }
        it { is_expected.to have_http_status(:ok) }
      end

      context 'when rendering errors is `false`' do
        let(:default_params) { { render_errors: false } }

        it_behaves_like 'an invalid trading partner redirect', :find_commodity_path, nil
        it_behaves_like 'an invalid trading partner redirect', :chapter_path, '01'
        it_behaves_like 'an invalid trading partner redirect', :heading_path, '1501'
        it_behaves_like 'an invalid trading partner redirect', :commodity_path, '2402201000'
      end
    end
  end
end
