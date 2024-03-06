require 'spec_helper'

RSpec.describe GreenLanes::CategoryAssessment do
  subject(:category_assessment) { build(:category_assessment) }

  describe '.relationships' do
    subject { described_class.relationships }

    let(:geographical_area) do
      %i[
        geographical_area
      ]
    end

    let(:excluded_geographical_areas) do
      %i[
        excluded_geographical_areas
      ]
    end

    it { is_expected.to include :geographical_area }
    it { is_expected.to include :excluded_geographical_areas }
  end
end
