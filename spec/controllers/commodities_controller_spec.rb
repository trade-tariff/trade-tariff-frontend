require 'spec_helper'

RSpec.describe CommoditiesController, type: :controller do
  describe 'GET to #show' do
    shared_examples_for 'a commodity controller response' do
      context 'with existing commodity id provided', vcr: { cassette_name: 'commodities#0101300000_xi' } do
        subject(:do_request) { get :show, params: { id: '0101300000' } }

        before { do_request }

        it { is_expected.to have_http_status(:success) }
        it { expect(assigns(:section)).to be_present }
        it { expect(assigns(:chapter)).to be_present }
        it { expect(assigns(:heading)).to be_present }
        it { expect(assigns(:declarable)).to be_present }
        it { expect(assigns(:rules_of_origin_schemes)).to be_nil }
      end

      context 'with non-existant commodity id provided', vcr: { cassette_name: 'commodities#show_0101999999' } do
        subject(:do_request) { get :show, params: { id: '0101999999' } }

        before do
          stub_api_request('/commodities/0101999999/validity_periods')
            .and_return jsonapi_error_response(404)
        end

        it { is_expected.to redirect_to heading_url('0101') }
      end

      context 'with non-declarable heading id provided' do
        subject(:do_request) { get :show, params: { id: '0101000000' } }

        before do
          query_params = {
            as_of: Time.zone.today,
            filter: { meursing_additional_code_id: nil },
          }

          stub_api_request('/headings/0101')
            .with(query: query_params)
            .and_return \
              jsonapi_response :heading,
                               attributes_for(:heading,
                                              goods_nomenclature_item_id: '0101000000')
        end

        it { is_expected.to redirect_to heading_path('0101') }
      end

      context 'with non-declarable commodity id provided',
              vcr: { cassette_name: 'commodities#show_0101999999' } do
        subject(:do_request) { get :show, params: { id: '0101999999' } }

        before do
          query_params = {
            as_of: Time.zone.today,
            filter: { meursing_additional_code_id: nil },
          }

          stub_api_request('/subheadings/0101999999-80')
            .with(query: query_params)
            .and_return \
              jsonapi_response :subheading,
                               attributes_for(:subheading,
                                              goods_nomenclature_item_id: '0101999999',
                                              producline_suffix: '80')
        end

        it { is_expected.to redirect_to subheading_path('0101999999-80') }
      end
    end

    context 'with XI site' do
      include_context 'with XI service'

      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:xi).and_call_original
        allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:uk).and_call_original
      end

      it_behaves_like 'a commodity controller response'

      it 'uses the xi service to load the declarable', vcr: { cassette_name: 'commodities#show_0101210000_xi' } do
        get :show, params: { id: '0101210000' }

        expect(TradeTariffFrontend::ServiceChooser).to have_received(:with_source).with(:xi)
      end

      it 'does not use the uk service to load the declarable', vcr: { cassette_name: 'commodities#show_0101210000_xi' } do
        get :show, params: { id: '0101210000' }

        expect(TradeTariffFrontend::ServiceChooser).not_to have_received(:with_source).with(:uk)
      end

      it 'sets the goods_nomenclature_code in the session', vcr: { cassette_name: 'commodities#show_0101210000_xi' } do
        get :show, params: { id: '0101210000' }

        expect(session[:goods_nomenclature_code]).to eq('0101210000')
      end
    end

    context 'with UK site' do
      include_context 'with UK service'

      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:xi).and_call_original
        allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:uk).and_call_original
      end

      let(:validity_periods) do
        attributes_for_list :validity_period, 2,
                            goods_nomenclature_item_id: commodity_id
      end
      let(:commodity_id) { '0101999999' } # commodity 0101999999 does not exist

      it_behaves_like 'a commodity controller response'

      context 'with non existing commodity id provided and validity_periods api',
              vcr: { cassette_name: 'commodities#show_0101999999' } do
        before do
          stub_api_request("/commodities/#{commodity_id}/validity_periods")
            .to_return jsonapi_response(:validity_periods, validity_periods)

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

      context 'with non existing commodity id provided and no validity_periods api',
              vcr: { cassette_name: 'commodities#show_0101999999' } do
        before do
          stub_api_request("/commodities/#{commodity_id}/validity_periods")
            .to_return jsonapi_error_response(404)

          TradeTariffFrontend::ServiceChooser.service_choice = nil
          get :show, params: { id: commodity_id }
        end

        it 'redirects to heading page (strips exceeding commodity id characters)' do
          expect(response).to redirect_to heading_url(id: commodity_id.first(4))
        end
      end

      context 'with commodity id that does not exist in provided date and validity_periods api',
              vcr: { cassette_name: 'commodities#show_010121000' } do
        let(:commodity_id) { '0101210000' } # commodity 0101210000 does not exist at 1st of Jan, 2000

        before do
          stub_api_request("/commodities/#{commodity_id}/validity_periods")
            .to_return jsonapi_response(:validity_periods, validity_periods)

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

      context 'with commodity id that does not exist in provided date and no validity_periods api',
              vcr: { cassette_name: 'commodities#show_010121000' } do
        let(:commodity_id) { '0101210000' } # commodity 0101210000 does not exist at 1st of Jan, 2000

        before do
          stub_api_request("/commodities/#{commodity_id}/validity_periods")
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
