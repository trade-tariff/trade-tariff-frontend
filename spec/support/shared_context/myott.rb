RSpec.shared_context 'with cached chapters' do
  let(:animals_section) { build(:section, title: 'Section 1', resource_id: 1) }
  let(:fish_section) { build(:section, title: 'Section 2', resource_id: 2) }
  let(:live_animals_chapter) { build(:chapter, goods_nomenclature_item_id: '01', to_s: 'Live animals') }
  let(:meat_chapter) { build(:chapter, goods_nomenclature_item_id: '02', to_s: 'Meat') }
  let(:fish_chapter) do
    build(
      :chapter,
      goods_nomenclature_item_id: '03',
      to_s: 'Fish and crustaceans, molluscs and other aquatic invertebrates',
    )
  end

  before do
    allow(Rails.cache).to receive(:resilient_fetch).and_call_original
    allow(Rails.cache).to receive(:resilient_fetch).with('all_sections_chapters', expires_in: 1.day)
      .and_return({ animals_section => [live_animals_chapter, meat_chapter], fish_section => [fish_chapter] })
  end
end
