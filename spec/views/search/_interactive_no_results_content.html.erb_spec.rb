RSpec.describe 'search/_interactive_no_results_content', type: :view do
  subject { render partial: 'search/interactive_no_results_content' }

  before do
    assign(:results, results)
    assign(:search, search)
  end

  let(:search) { Search.new(q: 'flimflammagoo', request_id: 'test-uuid-123', interactive_search: true) }
  let(:results) { Search::InternalSearchResult.new([], nil) }

  describe 'inset text' do
    it { is_expected.to have_css('.govuk-inset-text', text: 'You searched for') }
    it { is_expected.to have_css('.govuk-inset-text', text: 'flimflammagoo') }
  end

  describe 'tips' do
    it { is_expected.to have_css('h2', text: 'Tips for using guided search') }
    it { is_expected.to have_text('search in English only') }
    it { is_expected.to have_text('do not use any special characters') }
    it { is_expected.to have_text('enter as much detail about the product as possible') }
  end

  describe 'next steps' do
    it { is_expected.to have_css('h2', text: 'Next steps') }
    it { is_expected.to have_text('Go back and search again, browse the tariff or look for your product in the A-Z.') }
    it { is_expected.to have_link('Start search again', href: find_commodity_path) }
    it { is_expected.to have_link('Cancel', href: sections_path) }
  end

  describe 'sidebar' do
    it { is_expected.to have_text('Help and guidance') }
    it { is_expected.to have_link('What are commodity codes?') }
    it { is_expected.to have_link('Guidance on difficult to classify goods') }
    it { is_expected.to have_link('Ask for help on classifying your goods') }
  end

  describe 'alternative search cards' do
    it { is_expected.to have_css('h2', text: 'Other ways to search for a commodity') }
    it { is_expected.to have_link('Keyword or commodity code') }
    it { is_expected.to have_link('Goods classifications') }
    it { is_expected.to have_link('A-Z product index') }
  end
end
