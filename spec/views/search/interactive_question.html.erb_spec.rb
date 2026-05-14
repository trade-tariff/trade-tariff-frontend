RSpec.describe 'search/interactive_question', type: :view do
  subject { render }

  before do
    assign(:search, Search.new(q: 'citrus jam', request_id: 'test-uuid-123', interactive_search: true))
    assign(:results, Search::InternalSearchResult.new([], meta))
  end

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
end
