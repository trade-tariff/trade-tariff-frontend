RSpec.describe 'search/interactive_question', type: :view do
  subject { render }

  before do
    assign(:search, search)
    assign(:results, Search::InternalSearchResult.new([], meta))
  end

  let(:search) { Search.new('q' => 'citrus jam', 'request_id' => 'test-uuid-123', 'interactive_search' => true) }

  let(:meta) do
    {
      'interactive_search' => {
        'query' => 'citrus jam',
        'request_id' => 'test-uuid-123',
        'answers' => [
          { 'question' => 'What type of fruit?', 'options' => %w[Citrus Berry], 'answer' => nil },
        ],
      },
    }
  end

  it { is_expected.to have_css('h1', text: 'Search for a commodity') }
  it { is_expected.to have_link('Cancel', href: find_commodity_path) }

  context 'when the guided search was started for a historical date' do
    let(:search) do
      Search.new(
        'q' => 'citrus jam',
        'request_id' => 'test-uuid-123',
        'interactive_search' => true,
        'day' => '27',
        'month' => '3',
        'year' => '2021',
      )
    end

    it 'carries the date into the answer submission form' do
      render

      expect(rendered)
        .to have_css('input[type="hidden"][name="day"][value="27"]', visible: :hidden)
        .and have_css('input[type="hidden"][name="month"][value="3"]', visible: :hidden)
        .and have_css('input[type="hidden"][name="year"][value="2021"]', visible: :hidden)
    end
  end
end
