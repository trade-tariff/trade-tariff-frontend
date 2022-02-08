require 'spec_helper'

RSpec.describe CommoditiesController, type: :controller do
  describe 'GET to #show' do
    context 'with XI site' do
      include_context 'with XI service'

      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:xi).and_call_original
        allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:uk).and_call_original
      end

      it 'does not use with_source to fetch the commodity from the XI service', vcr: { cassette_name: 'commodities#show_0101210000_xi' } do
        get :show, params: { id: '0101210000' }

        expect(TradeTariffFrontend::ServiceChooser).not_to have_received(:with_source).with(:xi)
      end

      it 'fetches the commodity from the UK service', vcr: { cassette_name: 'commodities#show_0101210000_xi' } do
        get :show, params: { id: '0101210000' }

        expect(TradeTariffFrontend::ServiceChooser).to have_received(:with_source).with(:uk)
      end

      it 'sets the goods_nomenclature_code in the session', vcr: { cassette_name: 'commodities#show_0101210000_xi' } do
        get :show, params: { id: '0101210000' }

        expect(session[:goods_nomenclature_code]).to eq('0101210000')
      end

      context 'with existing commodity id provided' do
        subject { controller }

        before do
          VCR.use_cassette('commodities#0101300000_xi') do
            get :show, params: { id: '0101300000' }
          end
        end

        it { is_expected.to respond_with(:success) }
        it { expect(assigns(:section)).to be_present }
        it { expect(assigns(:chapter)).to be_present }
        it { expect(assigns(:heading)).to be_present }
        it { expect(assigns(:commodity)).to be_present }
        it { expect(assigns(:rules_of_origin_schemes)).to be_nil }
      end

      context 'with non-existant commodity id provided', vcr: { cassette_name: 'commodities#show_0101999999' } do
        let(:commodity_id) { '0101999999' } # commodity 0101999999 does not exist

        before do
          get :show, params: { id: commodity_id }
        end

        it 'redirects to heading page (strips exceeding commodity id characters)' do
          expect(response.status).to redirect_to heading_url(id: commodity_id.first(4))
        end
      end
    end

    context 'with UK site' do
      include_context 'with UK service'

      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:xi).and_call_original
        allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:uk).and_call_original
      end

      let(:commodity_id) { '0101999999' } # commodity 0101999999 does not exist

      let(:validity_dates) do
        attributes_for_list :validity_date, 2,
                            goods_nomenclature_item_id: commodity_id
      end

      context 'with non existing commodity id provided and validity_dates api',
              vcr: { cassette_name: 'commodities#show_0101999999' } do
        before do
          stub_api_request("/commodities/#{commodity_id}/validity_dates")
            .to_return jsonapi_response(:validity_dates, validity_dates)

          TradeTariffFrontend::ServiceChooser.service_choice = nil
          get :show, params: { id: commodity_id }
        end

        it 'responds with a 404' do
          expect(response).to have_http_status :not_found
        end

        it 'renders a custom 404 page' do
          expect(response).to render_template 'show_404'
        end
      end

      context 'with non existing commodity id provided and no validity_dates api',
              vcr: { cassette_name: 'commodities#show_0101999999' } do
        before do
          stub_api_request("/commodities/#{commodity_id}/validity_dates")
            .to_return jsonapi_error_response(404)

          TradeTariffFrontend::ServiceChooser.service_choice = nil
          get :show, params: { id: commodity_id }
        end

        it 'redirects to heading page (strips exceeding commodity id characters)' do
          expect(response).to redirect_to heading_url(id: commodity_id.first(4))
        end
      end

      context 'with commodity id that does not exist in provided date and validity_dates api',
              vcr: { cassette_name: 'commodities#show_010121000' } do
        let(:commodity_id) { '0101210000' } # commodity 0101210000 does not exist at 1st of Jan, 2000

        around do |example|
          Timecop.freeze(Time.zone.parse('2013-11-11 12:00:00')) do
            example.run
          end
        end

        before do
          stub_api_request("/commodities/#{commodity_id}/validity_dates")
            .to_return jsonapi_response(:validity_dates, validity_dates)

          TradeTariffFrontend::ServiceChooser.service_choice = nil
          get :show, params: { id: commodity_id, year: 2000, month: 1, day: 1, country: nil }
        end

        it 'responds with a 404' do
          expect(response).to have_http_status :not_found
        end

        it 'renders a custom 404 page' do
          expect(response).to render_template 'show_404'
        end
      end

      context 'with commodity id that does not exist in provided date and no validity_dates api',
              vcr: { cassette_name: 'commodities#show_010121000' } do
        let(:commodity_id) { '0101210000' } # commodity 0101210000 does not exist at 1st of Jan, 2000

        around do |example|
          Timecop.freeze(Time.zone.parse('2013-11-11 12:00:00')) do
            example.run
          end
        end

        before do
          stub_api_request("/commodities/#{commodity_id}/validity_dates")
            .to_return jsonapi_error_response(404)

          TradeTariffFrontend::ServiceChooser.service_choice = nil
          get :show, params: { id: commodity_id, year: 2000, month: 1, day: 1, country: nil }
        end

        it 'redirects to actual version of the commodity page' do
          expect(response).to redirect_to commodity_url(id: commodity_id.first(10))
        end
      end
    end
  end
end
