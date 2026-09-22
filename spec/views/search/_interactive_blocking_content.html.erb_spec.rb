RSpec.describe 'search/_interactive_blocking_content', type: :view do
  subject { render partial: 'search/interactive_blocking_content' }

  before do
    assign(:results, results)
    assign(:search, search)
  end

  let(:search) { Search.new(q: 'exampleterm', request_id: 'test-uuid-123', interactive_search: true) }
  let(:results) { Search::InternalSearchResult.new([], meta) }
  let(:meta) do
    {
      'interactive_search' => { 'query' => 'exampleterm', 'answers' => [] },
      'description_intercept' => {
        'excluded' => true,
        'message_header' => 'Example guidance header',
        'message' => 'Example guidance message body.',
      },
    }
  end

  describe 'actions' do
    it { is_expected.to have_link('Start search again', href: '/find_commodity?search_mode=guided') }
    it { is_expected.to have_link('Cancel', href: find_commodity_path) }
  end
end
