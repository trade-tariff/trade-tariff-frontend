require 'spec_helper'

RSpec.describe ::GreenLanes::DetermineNextPage do
  describe '#next_page' do
    subject do
      goods_nomenclature = build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
      described_class.new(goods_nomenclature)
        .next(cat_1_exemptions_apply:, cat_2_exemptions_apply:)
    end

    let(:cat_1_exemptions_apply) { nil }
    let(:cat_2_exemptions_apply) { nil }

    # [cat_3]
    context 'when there are no category assessments' do
      let(:assessments) { [] }

      it { is_expected.to eq('/green_lanes/check_your_answers') }
    end

    # [cat_1]
    context 'when there are Cat1 without exemptions' do
      let(:assessments) { [attributes_for(:category_assessment, category: 1)] }

      it { is_expected.to eq('/green_lanes/check_your_answers') }
    end

    # [cat_2]
    context 'when there are no Cat1 assessments AND there are Cat2 without exemptions' do
      let(:assessments) { [attributes_for(:category_assessment, category: 2)] }

      it { is_expected.to eq('/green_lanes/check_your_answers') }
    end

    # [cat_1, cat_2]
    context 'when there are Cat1 with exemptions AND Cat2 without exemptions' do
      let(:assessments) do
        [
          attributes_for(:category_assessment, :with_exemptions, category: 1),
          attributes_for(:category_assessment, category: 2),
        ]
      end

      context 'when Cat 1 exemptions question has not been answered' do
        let(:cat_1_exemptions_apply) { nil }

        it { is_expected.to eq('/green_lanes/applicable_exemptions/new?category=1') }
      end

      context 'when some Cat 1 exemptions apply' do
        let(:cat_1_exemptions_apply) { true }

        it { is_expected.to eq('/green_lanes/check_your_answers') }
      end

      context 'when NO Cat 1 exemptions apply' do
        let(:cat_1_exemptions_apply) { false }

        it { is_expected.to eq('/green_lanes/check_your_answers') }
      end
    end

    # [cat_1 cat_2 cat_3]
    context 'when there are Cat1 with exemptions AND there are Cat2 with exemptions' do
      let(:assessments) do
        [
          attributes_for(:category_assessment, :with_exemptions, category: 1),
          attributes_for(:category_assessment, :with_exemptions, category: 2),
        ]
      end

      context 'when Cat 1 exemptions questions apply AND Cat 2 exemptions questions apply' do
        let(:cat_1_exemptions_apply) { true }
        let(:cat_2_exemptions_apply) { true }

        it { is_expected.to eq('/green_lanes/check_your_answers') }
      end

      context 'when Cat 1 exemptions questions apply AND Cat 2 exemptions questions DO NOT apply' do
        let(:cat_1_exemptions_apply) { true }
        let(:cat_2_exemptions_apply) { false }

        it { is_expected.to eq('/green_lanes/check_your_answers') }
      end

      context 'when Cat 1 exemptions question has not been answered' do
        let(:cat_1_exemptions_apply) { nil }
        let(:cat_2_exemptions_apply) { nil }

        it { is_expected.to eq('/green_lanes/applicable_exemptions/new?category=1') }
      end

      context 'when some Cat 1 exemptions apply to the goods' do
        let(:cat_1_exemptions_apply) { true }
        let(:cat_2_exemptions_apply) { nil }

        it { is_expected.to eq('/green_lanes/applicable_exemptions/new?category=2&c1ex=true') }
      end

      context 'when NO Cat 1 exemptions apply to the goods' do
        let(:cat_1_exemptions_apply) { false }
        let(:cat_2_exemptions_apply) { nil }

        it { is_expected.to eq('/green_lanes/check_your_answers') }
      end
    end

    # [cat_2, cat_3]
    context 'when there are only Cat2 with exemptions' do
      let(:assessments) { [attributes_for(:category_assessment, :with_exemptions, category: 2)] }

      context 'when Cat 2 exemptions question has not been answered' do
        let(:cat_2_exemptions_apply) { nil }

        it { is_expected.to eq('/green_lanes/applicable_exemptions/new?category=2') }
      end

      context 'when some Cat 2 exemptions apply to the goods' do
        let(:cat_2_exemptions_apply) { true }

        it { is_expected.to eq('/green_lanes/check_your_answers') }
      end

      context 'when NO Cat 2 exemptions apply to the goods' do
        let(:cat_2_exemptions_apply) { false }

        it { is_expected.to eq('/green_lanes/check_your_answers') }
      end
    end

    # [cat_1, cat_3]
    context 'when there are only Cat1 with exemptions' do
      let(:assessments) { [attributes_for(:category_assessment, :with_exemptions, category: 1)] }

      context 'when Cat 1 exemptions question has not been answered' do
        let(:cat_1_exemptions_apply) { nil }

        it { is_expected.to eq('/green_lanes/applicable_exemptions/new?category=1') }
      end

      context 'when some Cat 1 exemptions apply to the goods' do
        let(:cat_1_exemptions_apply) { true }

        it { is_expected.to eq('/green_lanes/check_your_answers') }
      end

      context 'when NO Cat 1 exemptions apply to the goods' do
        let(:cat_1_exemptions_apply) { false }

        it { is_expected.to eq('/green_lanes/check_your_answers') }
      end
    end
  end
end
