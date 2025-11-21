require 'spec_helper'

RSpec.describe Myott::GroupedMeasureChangesController, type: :controller do
  describe 'GET #show' do
    let(:user_id_token) { 'token' }
    let(:as_of) { Time.zone.today }
    let(:grouped_measure_change) { instance_double(TariffChanges::GroupedMeasureChange) }

    before do
      allow(controller).to receive_messages(user_id_token: user_id_token, as_of: as_of, authenticate: true)
    end

    it 'assigns @grouped_measure_changes' do
      allow(TariffChanges::GroupedMeasureChange).to receive(:find).and_return(grouped_measure_change)
      get :show, params: { id: '1' }
      expect(assigns(:grouped_measure_changes)).to eq(grouped_measure_change)
    end

    it 'calls find with correct arguments' do
      allow(TariffChanges::GroupedMeasureChange).to receive(:find).and_return(grouped_measure_change)
      get :show, params: { id: '1' }
      expect(TariffChanges::GroupedMeasureChange).to have_received(:find).with('1', user_id_token, { as_of: as_of.strftime('%Y-%m-%d') })
    end
  end
end
