require 'spec_helper'

RSpec.describe HeadingsController, type: :controller do
  describe 'GET to #show' do
    before do
      allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_return('xi')
      allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:xi).and_call_original
      allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:uk).and_call_original
    end

    it 'does not use with_source to fetch the heading from the XI service', vcr: { cassette_name: 'headings#show_0110', record: :new_episodes } do
      get :show, params: { id: '0501' }

      expect(TradeTariffFrontend::ServiceChooser).not_to have_received(:with_source).with(:xi)
    end

    it 'fetches the heading from the UK service', vcr: { cassette_name: 'headings#show_0110' } do
      get :show, params: { id: '0501' }

      expect(TradeTariffFrontend::ServiceChooser).to have_received(:with_source).with(:uk)
    end

    it 'sets the goods_nomenclature_code', vcr: { cassette_name: 'headings#show_0110' } do
      get :show, params: { id: '0501' }

      expect(assigns(:goods_nomenclature_code)).to eq('0501')
    end

    context 'with existing heading id provided', vcr: { cassette_name: 'headings#show' } do
      let!(:heading) { Heading.new(attributes_for(:heading)) }

      before do
        get :show, params: { id: heading.to_param }
      end

      it { is_expected.to respond_with(:success) }
      it { expect(assigns(:heading)).to be_a(HeadingPresenter) }
      it { expect(assigns(:commodities)).to be_a(HeadingCommodityPresenter) }
      it { expect(assigns(:rules_of_origin_schemes)).to be_nil }
    end

    context 'with non-existent heading id provided', vcr: { cassette_name: 'headings#show_0110' } do
      let(:heading_id) { '0110' } # heading 0110 does not exist

      let(:validity_periods) do
        attributes_for_list :validity_period, 2,
                            goods_nomenclature_item_id: heading_id
      end

      before do
        stub_api_request("headings/#{heading_id}/validity_periods")
          .to_return periods_api

        get :show, params: { id: heading_id }
      end

      context 'when no validity_periods api available' do
        let(:periods_api) { jsonapi_error_response(404) }

        it 'redirects to sections index page as fallback' do
          expect(response.status).to redirect_to sections_url
        end
      end

      context 'when validity_periods api is available' do
        let(:periods_api) { jsonapi_response(:validity_periods, validity_periods) }

        it 'responds with a 404' do
          expect(response).to have_http_status :not_found
        end

        it 'renders a custom 404 page' do
          expect(response).to render_template 'show_404'
        end
      end
    end

    context 'when heading is declarable', vcr: { cassette_name: 'headings#show_0903' } do
      let(:heading_id) { '0903' } # heading is declarable

      it 'redirects to the relevant commodity' do
        get :show, params: { id: '0903' }

        expect(response.status).to redirect_to commodity_url(id: '0903000000')
      end
    end

    context 'with UK site' do
      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_call_original
      end

      context 'with non-existent chapter id provided', vcr: { cassette_name: 'headings#show_0110' } do
        let(:heading_id) { '0110' } # heading 0110 does not exist

        before do
          stub_api_request("headings/#{heading_id}/validity_periods")
            .to_return jsonapi_error_response(404)
          TradeTariffFrontend::ServiceChooser.service_choice = nil
          get :show, params: { id: heading_id }
        end

        it 'redirects to sections index page as fallback' do
          expect(response.status).to redirect_to sections_url
        end
      end
    end
  end
end
