require 'spec_helper'

RSpec.describe GreenLanes::CategoryAssessmentsController, type: :request do
  subject { make_request && response }

  let(:goods_nomenclature) { build :green_lanes_goods_nomenclature }

  describe 'GET #create' do
    before do
      allow(GreenLanes::GoodsNomenclature).to receive(:find)
                         .with(goods_nomenclature.goods_nomenclature_item_id)
                         .and_return goods_nomenclature
    end

    let(:make_request) { post green_lanes_category_assessments_path , params: { green_lanes_category_assessment_search: { commodity_code: goods_nomenclature.goods_nomenclature_item_id } }  }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end

  describe 'GET #show' do
    let(:make_request) { get green_lanes_category_assessments_path}

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
