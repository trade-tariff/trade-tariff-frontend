RSpec.describe Myott::GroupedMeasureChangesController, type: :controller do
  include MyottAuthenticationHelpers

  describe 'GET #show' do
    let(:user_id_token) { 'token' }
    let(:as_of) { Time.zone.today }
    let(:commodity_changes) { [build(:grouped_measure_commodity_change)] }
    let(:grouped_measure_change) do
      instance_double(TariffChanges::GroupedMeasureChange,
                      grouped_measure_commodity_changes: commodity_changes)
    end

    before do
      setup_mycommodities_context(user_id_token: user_id_token, as_of: as_of)
    end

    it 'assigns @grouped_measure_changes' do
      allow(TariffChanges::GroupedMeasureChange).to receive(:find).and_return(grouped_measure_change)
      get :show, params: { id: '1' }
      expect(assigns(:grouped_measure_changes)).to eq(grouped_measure_change)
    end

    it 'calls find with correct arguments' do
      allow(TariffChanges::GroupedMeasureChange).to receive(:find).and_return(grouped_measure_change)
      get :show, params: { id: '1' }
      expect(TariffChanges::GroupedMeasureChange).to have_received(:find).with(
        '1',
        user_id_token,
        hash_including(
          page: 1,
          per_page: 10,
          as_of: as_of.to_fs(:dashed),
        ),
      )
    end

    it 'calls find with custom pagination params' do
      allow(TariffChanges::GroupedMeasureChange).to receive(:find).and_return(grouped_measure_change)
      get :show, params: { id: '1', page: 3, per_page: 25 }
      expect(TariffChanges::GroupedMeasureChange).to have_received(:find).with(
        '1',
        user_id_token,
        hash_including(
          page: 3,
          per_page: 25,
          as_of: as_of.to_fs(:dashed),
        ),
      )
    end

    it 'assigns @commodity_changes from grouped_measure_changes' do
      allow(TariffChanges::GroupedMeasureChange).to receive(:find).and_return(grouped_measure_change)
      get :show, params: { id: '1' }
      expect(assigns(:commodity_changes)).to eq(commodity_changes)
    end
  end
end
