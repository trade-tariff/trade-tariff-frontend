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
