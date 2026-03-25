RSpec.describe Myott::CommodityChangesController, type: :controller do
  include MyottAuthenticationHelpers

  let(:as_of) { Time.zone.today }
  let(:commodity_change) { instance_double(TariffChanges::CommodityChange, count: 1, tariff_changes: []) }

  before do
    allow(TariffChanges::CommodityChange).to receive(:find).and_return(commodity_change)
  end

  describe 'GET #ending' do
    it_behaves_like 'a protected myott page', :ending

    context 'when user is authenticated' do
      before do
        subscription = setup_mycommodities_context(as_of: as_of)
        stub_current_subscription('my_commodities', subscription)
      end

      it 'assigns @change' do
        get :ending
        expect(assigns(:change)).to eq(commodity_change)
      end

      it 'renders the ending template' do
        get :ending
        expect(response).to render_template(:ending)
      end

      it 'falls back to yesterday when as_of is invalid' do
        allow(controller).to receive(:as_of).and_call_original

        get :ending, params: { as_of: 'not-a-date' }

        expect(TariffChanges::CommodityChange).to have_received(:find).with(
          'ending',
          anything,
          hash_including(as_of: Time.zone.yesterday.to_fs(:dashed)),
        )
      end
    end
  end

  describe 'GET #classification' do
    it_behaves_like 'a protected myott page', :classification

    context 'when user is authenticated' do
      before do
        subscription = setup_mycommodities_context(as_of: as_of)
        stub_current_subscription('my_commodities', subscription)
      end

      it 'assigns @change' do
        get :classification
        expect(assigns(:change)).to eq(commodity_change)
      end

      it 'renders the classification template' do
        get :classification
        expect(response).to render_template(:classification)
      end
    end
  end
end
