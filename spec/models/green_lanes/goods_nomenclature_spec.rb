require 'spec_helper'

RSpec.describe GreenLanes::GoodsNomenclature do
  subject(:goods_nomenclature) { build(:green_lanes_goods_nomenclature) }

  describe '.relationships' do
    subject { described_class.relationships }

    let(:applicable_category_assessments) do
      %i[
        applicable_category_assessments
      ]
    end

    it { is_expected.to include :applicable_category_assessments }
  end

  describe '#primary_assessments_group' do
    subject { goods_nomenclature.primary_assessments_group }

    let :goods_nomenclature do
      build :green_lanes_goods_nomenclature,
            applicable_category_assessments: assessments
    end

    context 'with only category 1' do
      let(:assessments) { attributes_for_pair :category_assessment, category: 1 }

      it { is_expected.to have_attributes length: 2 }
      it { is_expected.to all have_attributes category: 1 }
    end

    context 'with only category 2' do
      let(:assessments) { attributes_for_pair :category_assessment, category: 2 }

      it { is_expected.to have_attributes length: 2 }
      it { is_expected.to all have_attributes category: 2 }
    end

    context 'with mix of category 1 and category 2' do
      let :assessments do
        [
          attributes_for(:category_assessment, category: 2),
          attributes_for(:category_assessment, category: 1),
        ]
      end

      it { is_expected.to have_attributes length: 1 }
      it { is_expected.to all have_attributes category: 1 }
    end

    context 'with no assessments' do
      let(:assessments) { [] }

      it { is_expected.to have_attributes length: 0 }
      it { is_expected.to be_instance_of Array }
    end
  end
end
