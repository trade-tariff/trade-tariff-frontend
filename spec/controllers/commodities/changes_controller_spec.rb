require 'spec_helper'

RSpec.describe Commodities::ChangesController, type: :controller do
  describe 'GET #index' do
    context 'when the commodity exists' do
      before { get :index, params:, format: :atom }

      context 'when there are changes', vcr: { cassette_name: 'commodities_changes#index' } do
        let(:params) { { commodity_id: '0101210000' } }

        it { is_expected.to respond_with(:success) }
        it { expect(assigns(:changeable)).to be_present }
        it { expect(assigns(:changes)).to be_a(ChangesPresenter) }
      end

      context 'when there are no changes', vcr: { cassette_name: 'commodities_changes#index_0702000007_2020-07-22', record: :new_episodes }, type: :controller do
        let(:params) { { commodity_id: '0702000007', year: '2020', month: '07', day: '22' } }

        it { is_expected.to respond_with(:success) }
        it { expect(assigns(:changeable)).to be_present }
        it { expect(assigns(:changes)).to be_a(ChangesPresenter) }
        it { expect(assigns[:changes]).to be_empty }
      end
    end

    context 'when there is no commodity on that date', vcr: { cassette_name: 'commodities_changes#index_4302130000_2013-11-11' } do
      let(:params) { { commodity_id: '4302130000', year: '2013', month: '11', day: '11' } }

      it { expect {  get :index, params:, format: :atom  }.to raise_exception Faraday::ResourceNotFound }
    end
  end
end
