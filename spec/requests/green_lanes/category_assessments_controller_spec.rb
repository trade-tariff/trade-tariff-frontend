require 'spec_helper'

RSpec.describe GreenLanes::CategoryAssessmentsController, type: :request do
  subject { make_request && response }

  before do
    allow(TradeTariffFrontend).to receive(:green_lane_allowed?).and_return true
  end

  let(:goods_nomenclature) { build :green_lanes_goods_nomenclature }

  describe 'GET #create' do
    before do
      allow(GreenLanes::GoodsNomenclature).to receive(:find)
                         .with(goods_nomenclature.goods_nomenclature_item_id)
                         .and_return goods_nomenclature
    end

    let(:make_request) do
      post green_lanes_category_assessments_path, params: {
        green_lanes_category_assessment_search: {
          commodity_code: goods_nomenclature.goods_nomenclature_item_id,
        },
      }
    end

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end

  describe 'GET #show' do
    context 'when green lanes is allowed' do
      let(:make_request) { get green_lanes_category_assessments_path }

      it { is_expected.to have_http_status :ok }
      it { is_expected.to have_attributes content_type: %r{text/html} }
    end

    context 'when green lanes is not allowed' do
      before do
        allow(TradeTariffFrontend).to receive(:green_lane_allowed?).and_return false
      end

      let(:make_request) { get green_lanes_category_assessments_path }

      it { is_expected.to have_http_status :not_found }
      it { is_expected.to have_attributes content_type: %r{text/html} }
    end
  end
end
