require 'spec_helper'

RSpec.describe ::GreenLanes::DetermineCategory do
  describe '.call' do
    subject { described_class.new(goods_nomenclature).call }

    # Result 3
    context 'when there are no category assessments' do
      let(:goods_nomenclature) do
        build(:green_lanes_goods_nomenclature, applicable_category_assessments: [])
      end

      it { is_expected.to eq([:cat_3]) }
    end

    # Result 1
    context 'when there are category assessments' do
      context 'when there are Cat1 without exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, category: 1)] }

        it { is_expected.to eq([:cat_1]) }
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

        it { is_expected.to eq(%i[cat_1 cat_2]) }
      end

      # Result 2
      context 'when there are not Cat1 ' \
              'and there are Cat2 without exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, category: 2)] }

        it { is_expected.to eq([:cat_2]) }
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

        it { is_expected.to eq(%i[cat_1 cat_2 cat_3]) }
      end

      # Result 6
      context 'when there are Cat1 with exemptions ' \
              'and there are not Cat2' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, :with_exemptions, category: 1)] }

        it { is_expected.to eq(%i[cat_1 cat_3]) }
      end

      # Result 7
      context 'when there are not Cat1 ' \
              'and there are Cat2 with exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, :with_exemptions, category: 2)] }

        it { is_expected.to eq(%i[cat_2 cat_3]) }
      end
    end
  end
end
