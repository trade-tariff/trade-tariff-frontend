require 'spec_helper'

RSpec.describe GreenLanes::CategoryAssessmentsController, type: :request do
  subject { make_request && response }

  before do
    allow(TradeTariffFrontend).to receive(:green_lane_allowed?).and_return true
  end

  let(:goods_nomenclature) { build :green_lanes_goods_nomenclature }

  describe 'POST #create' do
    context 'search by commodity code' do
      before do
        allow(GreenLanes::GoodsNomenclature).to receive(:find)
                                                  .with(goods_nomenclature.goods_nomenclature_item_id,
                                                        filter: { geographical_area_id: ''})
                                                  .and_return goods_nomenclature
      end

      let(:make_request) { post green_lanes_category_assessments_path, params: {
        green_lanes_category_assessment_search: {
          commodity_code: goods_nomenclature.goods_nomenclature_item_id,
          country: ''
        } } }

      it { is_expected.to have_http_status :ok }
      it { is_expected.to have_attributes content_type: %r{text/html} }
    end

    context 'search by commodity code and geographical area' do
      before do
        allow(GreenLanes::GoodsNomenclature).to receive(:find)
                                                  .with(goods_nomenclature.goods_nomenclature_item_id,
                                                        filter: { geographical_area_id: 'FR'})
                                                  .and_return goods_nomenclature
      end

      let(:make_request) { post green_lanes_category_assessments_path, params: {
        green_lanes_category_assessment_search: {
          commodity_code: goods_nomenclature.goods_nomenclature_item_id,
          country: 'FR'
        } } }

      it { is_expected.to have_http_status :ok }
      it { is_expected.to have_attributes content_type: %r{text/html} }
    end
  end

  describe 'GET #show' do
    let(:make_request) { get green_lanes_category_assessments_path }

    before do
      allow(GeographicalArea).to receive(:country_options).and_return %w['France', 'FR']
    end

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
