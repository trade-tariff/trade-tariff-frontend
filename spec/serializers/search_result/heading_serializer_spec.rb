require 'spec_helper'

RSpec.describe SearchResult::HeadingSerializer do
  subject(:serializer) { described_class.new(heading) }

  let(:heading) { build(:heading) }

  describe '#as_json' do
    subject { serializer.as_json }

    it { is_expected.to include 'type' => 'heading' }
    it { is_expected.to include 'goods_nomenclature_item_id' => heading.goods_nomenclature_item_id }
    it { is_expected.to include 'description' => heading.description }
    it { is_expected.to include 'number_indents' => heading.number_indents }
    it { is_expected.to include 'producline_suffix' => heading.producline_suffix }
    it { is_expected.to include 'validity_start_date' => heading.validity_start_date.to_s }
    it { is_expected.to include 'validity_end_date' => heading.validity_end_date.to_s }
  end
end
