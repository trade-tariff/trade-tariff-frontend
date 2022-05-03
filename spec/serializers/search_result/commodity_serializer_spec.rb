require 'spec_helper'

RSpec.describe SearchResult::CommoditySerializer do
  subject(:serializer) { described_class.new(commodity) }

  let(:commodity) { build(:commodity) }

  describe '#as_json' do
    subject { serializer.as_json }

    it { is_expected.to include 'type' => 'commodity' }
    it { is_expected.to include 'goods_nomenclature_item_id' => commodity.goods_nomenclature_item_id }
    it { is_expected.to include 'declarable' => commodity.declarable }
    it { is_expected.to include 'description' => commodity.description }
    it { is_expected.to include 'number_indents' => commodity.number_indents }
    it { is_expected.to include 'producline_suffix' => commodity.producline_suffix }
    it { is_expected.to include 'validity_start_date' => commodity.validity_start_date.to_s }
    it { is_expected.to include 'validity_end_date' => commodity.validity_end_date.to_s }
  end
end
