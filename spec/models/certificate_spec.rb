require 'spec_helper'

RSpec.describe Certificate do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[measures]) }
  end

  describe '#all_goods_nomenclatures' do
    subject(:all_goods_nomenclatures) { build(:certificate, measures:).all_goods_nomenclatures.map(&:goods_nomenclature_item_id) }

    let(:measures) do
      [
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'DEF')),
        attributes_for(:measure, goods_nomenclature: attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'ABC')),
      ]
    end

    it { is_expected.to eq(%w[ABC DEF]) }
  end
end
