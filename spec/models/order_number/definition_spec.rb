require 'spec_helper'

RSpec.describe OrderNumber::Definition do
  subject(:definition) { build(:definition) }

  describe '#id' do
    it { expect(definition.id).to eq(definition.quota_definition_sid) }
  end

  describe '#geographical_areas' do
    it 'returns an empty array' do
      expect(definition.geographical_areas).to eq([])
    end

    context 'when the order number defines geographical areas' do
      subject(:definition) { build(:definition, order_number:) }

      let(:order_number) { attributes_for(:order_number, geographical_areas: [geographical_area]) }
      let(:geographical_area) { attributes_for(:geographical_area) }

      it 'returns the order number geographical areas' do
        expect(definition.geographical_areas.map(&:id)).to eq([geographical_area[:id]])
      end
    end

    context 'when the definition measures define geographical areas' do
      subject(:definition) { build(:definition, measures: [measure]) }

      let(:measure) { attributes_for(:measure, geographical_area:) }
      let(:geographical_area) { attributes_for(:geographical_area) }

      it 'returns the measure geographical areas' do
        expect(definition.geographical_areas.map(&:id)).to eq([geographical_area[:id]])
      end
    end
  end

  describe '#all_goods_nomenclatures' do
    subject(:definition) { build(:definition, measures:).all_goods_nomenclatures.map(&:goods_nomenclature_item_id) }

    let(:measures) do
      [
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'DEF')),
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'ABC')),
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'ABC')),
        attributes_for(:measure, goods_nomenclature: nil),
      ]
    end

    it { is_expected.to eq(%w[ABC DEF]) }
  end
end
