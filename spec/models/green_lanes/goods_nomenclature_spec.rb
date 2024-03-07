require 'spec_helper'

RSpec.describe GreenLanes::GoodsNomenclature do
  subject(:goods_nomenclature) { build(:goods_nomenclature) }

  describe '.relationships' do
    subject { described_class.relationships }

    let(:applicable_category_assessments) do
      %i[
        applicable_category_assessments
      ]
    end

    it { is_expected.to include :applicable_category_assessments }
  end
end
