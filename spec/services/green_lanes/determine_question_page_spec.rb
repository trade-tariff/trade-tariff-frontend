require 'spec_helper'

RSpec.describe ::GreenLanes::DetermineQuestionPage do
  describe '#next_page' do
    # [cat_3]
    context 'when there are no category assessments' do
      let(:goods_nomenclature) do
        build(:green_lanes_goods_nomenclature, applicable_category_assessments: [])
      end

      it 'next page is result' do
        expect(described_class.new(goods_nomenclature).next_page).to eq(:result)
      end
    end

    # [cat_1]
    context 'when there are category assessments' do
      context 'when there are Cat1 without exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, category: 1)] }

        it 'next page is result' do
          expect(described_class.new(goods_nomenclature).next_page).to eq(:result)
        end
      end

      # [cat_2]
      context 'when there are not Cat1 AND there are Cat2 without exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, category: 2)] }

        it 'next page is result' do
          expect(described_class.new(goods_nomenclature).next_page).to eq(:result)
        end
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

        it 'next page is cat_1_exemptions_questions' do
          expect(described_class.new(goods_nomenclature).next_page).to eq(:cat_1_exemptions_questions)
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

        it 'next page is cat_1_exemptions_questions' do
          expect(described_class.new(goods_nomenclature).next_page).to eq(:cat_1_exemptions_questions)
        end
      end

      # [cat1, cat_2, cat_3] + cat_1 question assessment
      # context 'when there are Cat1 with exemptions AND Cat2 with exemptions' \
      #         'and NOT Cat1 without exemptions AND NOT Cat2 without exemptions' do
      #   let(:goods_nomenclature) do
      #     build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
      #   end

      #   let(:assessments) do
      #     [
      #       attributes_for(:category_assessment, :with_exemptions, category: 1),
      #       attributes_for(:category_assessment, :with_exemptions, category: 2)
      #     ]
      #   end

      #   it 'next page is cat_2_exemptions_questions' do
      #     expect(
      #       described_class.new(goods_nomenclature).next_page(no_cat_1_exemptions_apply: true)
      #     ).to eq(:cat_2_exemptions_questions)
      #   end
      # end

      # [cat_2, cat_3]
      context 'when there are not Cat1 AND there are only Cat2 with exemptions' do
        let(:goods_nomenclature) do
          build(:green_lanes_goods_nomenclature, applicable_category_assessments: assessments)
        end

        let(:assessments) { [attributes_for(:category_assessment, :with_exemptions, category: 2)] }

        it 'next page is cat_1_exemptions_questions' do
          expect(described_class.new(goods_nomenclature).next_page).to eq(:cat_2_exemptions_questions)
        end
      end
    end
  end
end
