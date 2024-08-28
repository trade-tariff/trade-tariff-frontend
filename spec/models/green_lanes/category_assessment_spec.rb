require 'spec_helper'

RSpec.describe GreenLanes::CategoryAssessment do
  subject(:category_assessment) { build :category_assessment }

  describe '.relationships' do
    subject { described_class.relationships }

    it { is_expected.to include :geographical_area }
    it { is_expected.to include :excluded_geographical_areas }
    it { is_expected.to include :exemptions }
    it { is_expected.to include :theme }
    it { is_expected.to include :measure_type }
    it { is_expected.to include :regulation }
  end

  describe 'attributes' do
    it { is_expected.to have_attributes category: category_assessment.theme.category }
    it { is_expected.to have_attributes theme: category_assessment.theme }
  end

  describe '#id' do
    subject(:id) { build(:category_assessment).id }

    it { is_expected.to eq("category_assessment_#{category_assessment.resource_id}") }
  end

  describe '#answered_exemptions' do
    subject(:answered_exemptions) do
      category_assessment.answered_exemptions(answers).map(&:code)
    end

    let(:category_assessment) { build(:category_assessment, :with_exemptions) }

    context 'when there are no answers' do
      let(:answers) { {} }

      it { is_expected.to eq([]) }
    end

    context 'when there are answers' do
      let(:answers) do
        {
          category_assessment.category.to_s => {
            category_assessment.resource_id => [category_assessment.exemptions.first.code],
          },
        }
      end

      it { is_expected.to eq([category_assessment.exemptions.first.code]) }
    end
  end
end
