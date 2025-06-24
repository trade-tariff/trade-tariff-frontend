RSpec.shared_context 'with cached chapters' do
  let(:section1) { build(:section, title: 'Section 1', resource_id: 1) }
  let(:section2) { build(:section, title: 'Section 2', resource_id: 2) }
  let(:chapter1) { build(:chapter, goods_nomenclature_item_id: '01', to_s: 'Live animals') }
  let(:chapter2) { build(:chapter, goods_nomenclature_item_id: '02', to_s: 'Meat') }
  let(:chapter3) { build(:chapter, goods_nomenclature_item_id: '03', to_s: 'Fish and crustaceans, molluscs and other aquatic invertebrates') }

  before do
    allow(Rails.cache).to receive(:fetch).and_call_original
    allow(Rails.cache).to receive(:fetch).with('all_sections_chapters', expires_in: 1.day)
      .and_return({ section1 => [chapter1, chapter2], section2 => [chapter3] })
  end
end
