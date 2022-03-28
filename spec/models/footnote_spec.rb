require 'spec_helper'

RSpec.describe Footnote do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[measures goods_nomenclatures]) }
  end

  describe '#all_goods_nomenclatures' do
    subject(:all_goods_nomenclatures) { build(:footnote, measures:, goods_nomenclatures:).all_goods_nomenclatures.map(&:goods_nomenclature_item_id) }

    let(:measures) do
      [
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'DEF')), # Unsorted
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'ABC')), # Unsorted
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'ABC')), # Duplicate
        attributes_for(:measure, goods_nomenclature: nil), # Compacted
      ]
    end

    let(:goods_nomenclatures) do
      [
        attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'ABC'), # Duplicate
        attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'GHI'),
      ]
    end

    it { is_expected.to eq(%w[ABC DEF GHI]) }
  end
end
