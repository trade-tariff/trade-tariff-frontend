RSpec.describe Myott::GroupedMeasureCommodityChangesController, type: :controller do
  include MyottAuthenticationHelpers

  let(:user_id_token) { 'test-token' }
  let(:id) { 'import_IL__0807190050' }
  let(:as_of) { Time.zone.today.strftime('%Y-%m-%d') }
  let(:commodity_hash) { { goods_nomenclature_item_id: '0807190050', classification_description: 'Test commodity' } }
  let(:grouped_measure_change_hash) { { trade_direction: 'import', geographical_area_description: 'Israel' } }
  let(:mock_change) do
    change = build(:grouped_measure_commodity_change)
    change.commodity = commodity_hash
    change.grouped_measure_change = grouped_measure_change_hash
    change
  end

  before do
    subscription = setup_mycommodities_context(user_id_token: user_id_token, as_of: Time.zone.today)
    stub_current_subscription('my_commodities', subscription)
  end

  describe 'GET #show' do
    before do
      allow(TariffChanges::GroupedMeasureCommodityChange).to receive(:find)
        .with(id, user_id_token, { as_of: as_of })
        .and_return(mock_change)
    end

    it 'returns http success' do
      get :show, params: { id: id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns grouped_measure_commodity_changes' do
      get :show, params: { id: id }
      expect(assigns(:grouped_measure_commodity_changes)).to eq(mock_change)
    end
  end
end
