RSpec.describe Myott::CommodityChangesController, type: :controller do
  let(:user_id_token) { 'test_token' }
  let(:as_of) { Time.zone.today }
  let(:commodity_change) { instance_double(TariffChanges::CommodityChange, count: 1, tariff_changes: []) }

  before do
    allow(controller).to receive_messages(user_id_token: user_id_token, as_of: as_of)
    allow(TariffChanges::CommodityChange).to receive(:find).and_return(commodity_change)
    allow(controller).to receive(:authenticate)
  end

  describe 'GET #ending' do
    it 'assigns @change' do
      get :ending
      expect(assigns(:change)).to eq(commodity_change)
    end

    it 'renders the ending template' do
      get :ending
      expect(response).to render_template(:ending)
    end
  end

  describe 'GET #classification' do
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
