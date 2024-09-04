require 'spec_helper'

RSpec.describe ::GreenLanes::DetermineCandidateCategories do
  describe '.categories' do
    subject { described_class.new(goods_nomenclature).categories }

    # Result 3
    context 'when there are no category assessments' do
      let(:goods_nomenclature) do
        build(:green_lanes_goods_nomenclature, applicable_category_assessments: [])
      end

      it { is_expected.to eq([3]) }
    end

    # Result 1
    context 'when there are category assessments' do
      context 'when there are Cat1 without exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, category: 1)] }

        it { is_expected.to eq([1]) }
      end

      # Result 4
      context 'when there are Cat1 with exemptions ' \
              'and Cat2 without exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) do
          [
            attributes_for(:category_assessment, :with_exemptions, category: 1),
            attributes_for(:category_assessment, category: 2),
          ]
        end

        it { is_expected.to eq([1, 2]) }
      end

      # Result 2
      context 'when there are not Cat1 ' \
              'and there are Cat2 without exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, category: 2)] }

        it { is_expected.to eq([2]) }
      end

      # Result 5
      context 'when there are Cat1 with exemptions ' \
              'and there are Cat2 with exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) do
          [
            attributes_for(:category_assessment, :with_exemptions, category: 1),
            attributes_for(:category_assessment, :with_exemptions, category: 2),
          ]
        end

        it { is_expected.to eq([1, 2, 3]) }
      end

      # Result 6
      context 'when there are Cat1 with exemptions ' \
              'and there are not Cat2' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, :with_exemptions, category: 1)] }

        it { is_expected.to eq([1, 3]) }
      end

      # Result 7
      context 'when there are not Cat1 ' \
              'and there are Cat2 with exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, :with_exemptions, category: 2)] }

        it { is_expected.to eq([2, 3]) }
      end
    end
  end

  describe '#cat1_without_exemptions' do
    subject(:cat1_without_exemptions) do
      described_class.new(goods_nomenclature).cat1_without_exemptions
    end

    let(:goods_nomenclature) do
      build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
    end

    let(:assessments) do
      [
        attributes_for(:category_assessment, category: 1),
        attributes_for(:category_assessment, :with_exemptions, category: 1),
        attributes_for(:category_assessment, category: 2),
        attributes_for(:category_assessment, category: 2),
        attributes_for(:category_assessment, :with_exemptions, category: 2),
      ]
    end

    it 'returns only Cat1 assessments without exemptions' do
      expect(cat1_without_exemptions.count).to eq(1)
    end
  end

  describe '#cat2_without_exemptions' do
    subject(:cat2_without_exemptions) do
      described_class.new(goods_nomenclature).cat2_without_exemptions
    end

    let(:goods_nomenclature) do
      build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
    end

    let(:assessments) do
      [
        attributes_for(:category_assessment, category: 1),
        attributes_for(:category_assessment, :with_exemptions, category: 1),
        attributes_for(:category_assessment, category: 2),
        attributes_for(:category_assessment, category: 2),
        attributes_for(:category_assessment, :with_exemptions, category: 2),
      ]
    end

    it 'returns only Cat2 assessments without exemptions' do
      expect(cat2_without_exemptions.count).to eq(2)
    end
  end
end
