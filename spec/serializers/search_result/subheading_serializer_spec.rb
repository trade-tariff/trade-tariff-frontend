require 'spec_helper'

RSpec.describe SearchResult::SubheadingSerializer do
  subject(:serializer) { described_class.new(subheading) }

  let(:subheading) { build(:subheading) }

  describe '#as_json' do
    subject { serializer.as_json }

    it { is_expected.to include 'type' => 'subheading' }
    it { is_expected.to include 'goods_nomenclature_item_id' => subheading.goods_nomenclature_item_id }
    it { is_expected.to include 'declarable' => false }
    it { is_expected.to include 'description' => subheading.description }
    it { is_expected.to include 'number_indents' => subheading.number_indents }
    it { is_expected.to include 'producline_suffix' => subheading.producline_suffix }
    it { is_expected.to include 'validity_start_date' => subheading.validity_start_date.to_s }
    it { is_expected.to include 'validity_end_date' => subheading.validity_end_date.to_s }
  end
end
