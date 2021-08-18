require 'spec_helper'

describe HeadingsController, type: :controller do
  describe 'GET to #show' do
    before do
      allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_return('xi')
      allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:xi).and_call_original
      allow(TradeTariffFrontend::ServiceChooser).to receive(:with_source).with(:uk).and_call_original
    end

    it 'doesn\'t uses with_source to fetch the heading from the XI service', vcr: { cassette_name: 'headings#show_0110', record: :new_episodes } do
      get :show, params: { id: '0501' }

      expect(TradeTariffFrontend::ServiceChooser).not_to have_received(:with_source).with(:xi)
    end

    it 'fetches the heading from the UK service', vcr: { cassette_name: 'headings#show_0110' } do
      get :show, params: { id: '0501' }

      expect(TradeTariffFrontend::ServiceChooser).to have_received(:with_source).with(:uk)
    end

    context 'with existing heading id provided', vcr: { cassette_name: 'headings#show' } do
      let!(:heading) { Heading.new(attributes_for(:heading).stringify_keys) }

      before do
        get :show, params: { id: heading.to_param }
      end

      it { is_expected.to respond_with(:success) }
      it { expect(assigns(:heading)).to be_a(HeadingPresenter) }
      it { expect(assigns(:commodities)).to be_a(HeadingCommodityPresenter) }
      it { expect(assigns(:rules_of_origin)).to eql [] }
    end

    context 'with non-existent chapter id provided', vcr: { cassette_name: 'headings#show_0110' } do
      let(:heading_id) { '0110' } # heading 0110 does not exist

      before do
        get :show, params: { id: heading_id }
      end

      it 'redirects to sections index page as fallback' do
        expect(response.status).to redirect_to sections_url
      end
    end

    context 'with UK site' do
      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_call_original
      end

      context 'with non-existent chapter id provided', vcr: { cassette_name: 'headings#show_0110' } do
        let(:heading_id) { '0110' } # heading 0110 does not exist

        before do
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
