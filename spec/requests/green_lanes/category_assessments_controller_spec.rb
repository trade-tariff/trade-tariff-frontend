require 'spec_helper'

RSpec.describe GreenLanes::CategoryAssessmentsController, type: :request do
  subject { make_request && response }

  before do
    allow(TradeTariffFrontend).to receive(:green_lane_allowed?).and_return true
  end

  let(:goods_nomenclature) { build :green_lanes_goods_nomenclature }

  describe 'POST #create' do
    context 'when search by commodity code' do
      before do
        allow(GreenLanes::GoodsNomenclature).to receive(:find)
                                                  .with(goods_nomenclature.goods_nomenclature_item_id,
                                                        filter: { geographical_area_id: '' })
                                                  .and_return goods_nomenclature
      end

      let(:make_request) do
        post green_lanes_category_assessments_path, params: {
          green_lanes_category_assessment_search: {
            commodity_code: goods_nomenclature.goods_nomenclature_item_id,
            country: '',
          },
        }
      end

      it { is_expected.to have_http_status :ok }
      it { is_expected.to have_attributes content_type: %r{text/html} }
    end

    context 'when search by commodity code and geographical area' do
      before do
        allow(GreenLanes::GoodsNomenclature).to receive(:find)
                                                  .with(goods_nomenclature.goods_nomenclature_item_id,
                                                        filter: { geographical_area_id: 'FR' })
                                                  .and_return goods_nomenclature
      end

      let(:make_request) do
        post green_lanes_category_assessments_path, params: {
          green_lanes_category_assessment_search: {
            commodity_code: goods_nomenclature.goods_nomenclature_item_id,
            country: 'FR',
          },
        }
      end

      it { is_expected.to have_http_status :ok }
      it { is_expected.to have_attributes content_type: %r{text/html} }
    end
  end

  describe 'GET #show' do
    context 'when green lanes is allowed' do
      let(:make_request) { get green_lanes_category_assessments_path }
      let(:countries) { build_list :geographical_area, 2 }

      before do
        allow(GeographicalArea).to receive(:all).and_return countries
      end

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
