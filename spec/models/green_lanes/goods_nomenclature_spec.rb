require 'spec_helper'

RSpec.describe GreenLanes::GoodsNomenclature do
  subject(:goods_nomenclature) { build(:goods_nomenclature) }

  describe '.relationships' do
    let(:expected_relationships) do
      %i[
        applicable_category_assessments
      ]
    end

    it { expect(described_class.relationships).to match_array(expected_relationships) }
  end
end
