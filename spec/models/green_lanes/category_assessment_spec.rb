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
end
