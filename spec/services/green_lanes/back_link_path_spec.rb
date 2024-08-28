require 'spec_helper'

RSpec.describe GreenLanes::BackLinkPath do
  subject(:back_link_path) do
    described_class.new(
      params:,
      category_one_assessments_without_exemptions:,
      category_two_assessments_without_exemptions:,
    ).call
  end

  let(:params) do
    {
      commodity_code: '1234',
      country_of_origin: 'USA',
      moving_date: '2024-01-01',
      ans: answers,
      c1ex: 'true',
      c2ex: 'false',
    }
  end

  let(:answers) { {} }

  let(:category_one_assessments_without_exemptions) { [] }
  let(:category_two_assessments_without_exemptions) { [] }

  describe '#call' do
    # These test have been created to cover all examples of where the user
    # is in the flow not having to worry about their current page
    context 'when the user has answered questions to cat 2 exemptions' do
      let(:answers) do
        {
          '1' => { '8564c4515a310042a7249c5rh31bd57e' => %w[Y056] },
          '2' => { '5667f4372c241642a7683c3aa38ed31e' => %w[Y900] },
        }
      end

      it 'returns the path for cat 2 questions', :aggregate_failures do
        expect(back_link_path).to include('/category_exemptions/new?ans')
        expect(back_link_path).to include('category=2')
      end
    end

    context 'when the user has answered questions to cat 1 but there are no cat 2 exemptions' do
      let(:answers) { { '1' => { '5667f4515c310042a7349c3aa31bd57e' => %w[Y900] } } }
      let(:category_two_assessments_without_exemptions) { %w[assessment] }

      it 'returns the path for cat 1 questions', :aggregate_failures do
        expect(back_link_path).to include('/category_exemptions/')
        expect(back_link_path).to include('category=1')
      end
    end

    context 'when the user has no cat 1 answers and no cat 2 answers' do
      let(:answers) { {} }

      it 'returns the path for moving requirements' do
        expect(back_link_path).to include('/your_goods/new?commodity_code')
      end
    end

    context 'when there are no cat 1 exemptions and no cat 2 exemptions' do
      let(:answers) { {} }
      let(:category_one_assessments_without_exemptions) { %w[assessment] }
      let(:category_two_assessments_without_exemptions) { %w[assessment] }

      it 'returns the path for moving requirements' do
        expect(back_link_path).to include('/your_goods/new?commodity_code')
      end
    end

    context 'when the user has no cat 2 answers and there are no category 1 exemptions' do
      let(:category_one_assessments_without_exemptions) { %w[assessment] }
      let(:answers) { {} }

      it 'returns the path for moving requirements' do
        expect(back_link_path).to include('/your_goods/new?commodity_code')
      end
    end
  end
end
