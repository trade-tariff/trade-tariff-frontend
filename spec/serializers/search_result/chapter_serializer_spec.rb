require 'spec_helper'

RSpec.describe SearchResult::ChapterSerializer do
  subject(:serializer) { described_class.new(chapter) }

  let(:chapter) { build(:chapter) }

  describe '#as_json' do
    subject { serializer.as_json }

    it { is_expected.to include 'type' => 'chapter' }
    it { is_expected.to include 'goods_nomenclature_item_id' => chapter.goods_nomenclature_item_id }
    it { is_expected.to include 'description' => chapter.description }
  end
end
