require 'spec_helper'

RSpec.describe Footnote do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[measures goods_nomenclatures]) }
  end

  it_behaves_like 'an entity that has goods nomenclatures' do
    let(:entity) { build(:footnote, measures: measures, goods_nomenclatures: goods_nomenclatures) }

    let(:goods_nomenclatures) do
      [
        attributes_for(:goods_nomenclature, goods_nomenclature_item_id: 'ABC'), # Duplicate
      ]
    end
  end
end
