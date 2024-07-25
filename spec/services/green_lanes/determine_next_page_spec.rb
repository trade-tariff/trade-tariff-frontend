require 'spec_helper'

RSpec.describe ::GreenLanes::DetermineNextPage do
  describe '#next_page' do
    subject do
      described_class.new(goods_nomenclature)
        .next(cat_1_exemptions_apply:, cat_2_exemptions_apply:)
    end

    let(:cat_1_exemptions_apply) { nil }
    let(:cat_2_exemptions_apply) { nil }

    # [cat_3]
    context 'when there are no category assessments' do
      let(:goods_nomenclature) do
        build(:green_lanes_goods_nomenclature, applicable_category_assessments: [])
      end

      it { is_expected.to eq(:result_cat_3) }
    end

    # [cat_1]
    context 'when there are Cat1 without exemptions' do
      let(:goods_nomenclature) do
        build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
      end

      let(:assessments) { [attributes_for(:category_assessment, category: 1)] }

      it { is_expected.to eq(:result_cat_1) }
    end

    # [cat_2]
    context 'when there are not Cat1 AND there are Cat2 without exemptions' do
      let(:goods_nomenclature) do
        build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
      end

      let(:assessments) { [attributes_for(:category_assessment, category: 2)] }

      it { is_expected.to eq(:result_cat_2) }
    end

    # [cat_1, cat_2]
    context 'when there are Cat1 with exemptions AND Cat2 without exemptions' do
      let(:goods_nomenclature) do
        build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
      end

      let(:assessments) do
        [
          attributes_for(:category_assessment, :with_exemptions, category: 1),
          attributes_for(:category_assessment, category: 2),
        ]
      end

      context 'when Cat 1 exemptions question has not been answered' do
        let(:cat_1_exemptions_apply) { nil }

        it { is_expected.to eq(:cat_1_exemptions_questions) }
      end

      context 'when some Cat 1 exemptions apply' do
        let(:cat_1_exemptions_apply) { true }

        it { is_expected.to eq(:result_cat_2) }
      end

      context 'when NO Cat 1 exemptions apply' do
        let(:cat_1_exemptions_apply) { false }

        it { is_expected.to eq(:result_cat_1) }
      end
    end

    # [cat_1 cat_2 cat_3]
    context 'when there are Cat1 with exemptions AND there are Cat2 with exemptions' do
      let(:goods_nomenclature) do
        build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
      end

      let(:assessments) do
        [
          attributes_for(:category_assessment, :with_exemptions, category: 1),
          attributes_for(:category_assessment, :with_exemptions, category: 2),
        ]
      end

      context 'when Cat 1 exemptions question has not been answered' do
        let(:cat_1_exemptions_apply) { nil }

        it { is_expected.to eq(:cat_1_exemptions_questions) }
      end

      context 'when some Cat 1 exemptions apply to the goods' do
        let(:cat_1_exemptions_apply) { true }

        it { is_expected.to eq(:cat_2_exemptions_questions) }
      end

      context 'when NO Cat 1 exemptions apply to the goods' do
        let(:cat_1_exemptions_apply) { false }

        it { is_expected.to eq(:result_cat_1) }
      end
    end

    # [cat_2, cat_3]
    context 'when there are not Cat1 AND there are only Cat2 with exemptions' do
      let(:goods_nomenclature) do
        build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
      end

      let(:assessments) { [attributes_for(:category_assessment, :with_exemptions, category: 2)] }

      context 'when Cat 2 exemptions question has not been answered' do
        let(:cat_2_exemptions_apply) { nil }

        it { is_expected.to eq(:cat_2_exemptions_questions) }
      end

      context 'when some Cat 2 exemptions apply to the goods' do
        let(:cat_2_exemptions_apply) { true }

        it { is_expected.to eq(:result_cat_3) }
      end

      context 'when NO Cat 2 exemptions apply to the goods' do
        let(:cat_2_exemptions_apply) { false }

        it { is_expected.to eq(:result_cat_2) }
      end
    end
  end
end
