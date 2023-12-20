RSpec.describe 'search/search', type: :view do
  subject { render }

  before do
    assign(:results, outcome)
    assign(:search, search)
  end

  let(:outcome) { build(:search_outcome, :fuzzy_match) }
  let(:search) { build(:search, q: 'toothbrush') }

  it { is_expected.to have_css('article.search-results > table > caption', text: 'Best commodity matches for') }
  it { is_expected.to have_css('.commodity-result', count: 2) }
end
