require 'spec_helper'

RSpec.describe GreenLanes::CategoryAssessment do
  subject(:category_assessment) { build(:category_assessment) }

  describe '.relationships' do
    let(:expected_relationships) do
      %i[
        geographical_area
        excluded_geographical_areas
      ]
    end

    it { expect(described_class.relationships).to match_array(expected_relationships) }
  end
end
