require 'spec_helper'

RSpec.describe GreenLanes::CategoryAssessmentsController, type: :controller do

  describe 'GET #search' do
    subject(:do_response) { get :search, params: }

    context 'when get search' do
      let(:params) { { commodity_code: '010122' } }
      let(:goods_nomenclature) { build(:goods_nomenclature) }

      before do
        allow(GreenLanes::GoodsNomenclature).to receive(:find)
      end

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('green_lanes/category_assessments/search') }
    end
  end
end
