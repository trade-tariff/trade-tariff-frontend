require 'spec_helper'

RSpec.describe GreenLanes::BackLinkPath do
  subject(:back_link_path) do
    described_class.new(
      current_page: :new_applicable_exemptions,
      params:,
      category_one_assessments_without_exemptions:,
      category_two_assessments_without_exemptions:,
    )
  end

  let(:params) do
    {
      commodity_code: '1234',
      country_of_origin: 'USA',
      moving_date: '2024-01-01',
      ans: { '1' => {}, '2' => {} },
      c1ex: 'true',
      c2ex: 'false',
    }
  end

  let(:category_one_assessments_without_exemptions) { [] }
  let(:category_two_assessments_without_exemptions) { [] }

  describe '#call' do
    context 'when category two has assessments without exemptions' do
      let(:category_two_assessments_without_exemptions) { %w[assessment] }

      it 'returns the path for new applicable exemptions' do
        expect(back_link_path.call).to include('/green_lanes/applicable_exemptions/new')
      end
    end

    # Add more tests for different scenarios
  end
end
