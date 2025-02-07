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
    it { is_expected.to include :ancestors }
    it { is_expected.to include :descendants }
  end

  describe '#filter_by_category' do
    subject { goods_nomenclature.filter_by_category(category) }

    let(:goods_nomenclature) do
      build :green_lanes_goods_nomenclature,
            applicable_category_assessments: assessments
    end

    context 'when filtering for category 1' do
      let(:category) { 1 }
      let(:assessments) { attributes_for_pair :category_assessment, category: 1 }

      it { is_expected.to all have_attributes category: 1 }
      it { is_expected.to have_attributes length: 2 }
    end

    context 'when there are no assessments for the given category' do
      let(:category) { 3 }
      let(:assessments) { attributes_for_pair :category_assessment, category: 1 }

      it { is_expected.to eq([]) }
    end
  end

  describe '#declarable?' do
    subject { goods_nomenclature.declarable? }

    context 'when producline_suffix is 80' do
      before { goods_nomenclature.producline_suffix = '80' }

      it { is_expected.to be true }
    end

    context 'when producline_suffix is not 80' do
      before { goods_nomenclature.producline_suffix = '10' }

      it { is_expected.to be false }
    end
  end

  describe '#get_declarable' do
    subject { goods_nomenclature.get_declarable }

    context 'when the goods_nomenclature is declarable' do
      before { goods_nomenclature.producline_suffix = '80' }

      it { is_expected.to eq(goods_nomenclature) }
    end
  end

  describe '#grouped_assessments' do
    subject(:grouped_assessments) { goods_nomenclature.grouped_assessments }

    let(:goods_nomenclature) do
      build :green_lanes_goods_nomenclature,
            applicable_category_assessments: assessments
    end

    context 'when there are multiple categories' do
      let(:assessments) do
        [
          attributes_for(:category_assessment, category: 1),
          attributes_for(:category_assessment, category: 2),
          attributes_for(:category_assessment, category: 1),
        ]
      end

      it 'groups assessments by category', :aggregate_failures do
        expect(grouped_assessments.keys).to contain_exactly(1, 2)
        expect(grouped_assessments[1].length).to eq(2)
        expect(grouped_assessments[2].length).to eq(1)
      end
    end

    context 'when there are no assessments' do
      let(:assessments) { [] }

      it { is_expected.to be_empty }
    end
  end

  describe '#primary_assessments_group' do
    subject { goods_nomenclature.primary_assessments_group }

    let :goods_nomenclature do
      build :green_lanes_goods_nomenclature,
            applicable_category_assessments: assessments
    end

    context 'with only category 1 assessments' do
      let(:assessments) { attributes_for_pair :category_assessment, category: 1 }

      it { is_expected.to have_attributes length: 2 }
      it { is_expected.to all have_attributes category: 1 }
    end

    context 'with only category 2 assessments' do
      let(:assessments) { attributes_for_pair :category_assessment, category: 2 }

      it { is_expected.to have_attributes length: 2 }
      it { is_expected.to all have_attributes category: 2 }
    end

    context 'with both of category 1 and category 2 assessments' do
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

  describe '#descriptions_with_other_handling' do
    subject(:descriptions_with_other_handling) do
      build(
        :green_lanes_goods_nomenclature,
        ancestors:,
        formatted_description:,
      ).descriptions_with_other_handling
    end

    context 'when the commodity does not have `other` as a description' do
      let(:formatted_description) { 'Mules' }

      let(:ancestors) do
        [
          attributes_for(:chapter, formatted_description: 'Live animals '),
          attributes_for(:heading, formatted_description: 'Live horses, asses, mules and hinnies '),
          attributes_for(:subheading, formatted_description: 'Horses'),
        ]
      end

      it { is_expected.to eq([]) }
    end

    context 'when the subheading has a non other description' do
      let(:formatted_description) { 'Other' }
      let(:ancestors) do
        [
          attributes_for(:chapter, formatted_description: 'Live animals '),
          attributes_for(:heading, formatted_description: 'Live horses, asses, mules and hinnies '),
          attributes_for(:subheading, formatted_description: 'Horses'),
        ]
      end

      it { is_expected.to eq(%w[Horses]) }
    end

    context 'when the heading has the non other description' do
      let(:formatted_description) { 'Other' }
      let(:ancestors) do
        [
          attributes_for(:chapter, formatted_description: 'Live animals '),
          attributes_for(:heading, formatted_description: 'Live horses, asses, mules and hinnies'),
          attributes_for(:subheading, formatted_description: 'Other'),
          attributes_for(:subheading, formatted_description: 'Other'),
        ]
      end

      it { is_expected.to eq(['Live horses, asses, mules and hinnies', 'Other', 'Other']) }
    end
  end
end
