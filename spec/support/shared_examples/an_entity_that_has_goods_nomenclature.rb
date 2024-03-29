RSpec.shared_examples 'an entity that has goods nomenclatures' do
  describe '#all_goods_nomenclatures' do
    subject(:all_goods_nomenclatures) { entity.all_goods_nomenclatures.map(&:goods_nomenclature_item_id) }

    let(:measures) do
      [
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'DEF')), # Unsorted
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'ABC')), # Unsorted
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'ABC')), # Duplicate
        attributes_for(:measure, goods_nomenclature: nil), # Compacted
      ]
    end

    it { is_expected.to eq(%w[ABC DEF]) }
  end
end
