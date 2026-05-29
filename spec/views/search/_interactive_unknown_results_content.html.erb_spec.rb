RSpec.describe 'search/_interactive_unknown_results_content', type: :view do
  subject { render partial: 'search/interactive_unknown_results_content' }

  before do
    assign(:results, results)
    assign(:search, search)
  end

  let(:search) { Search.new(q: 'flimflammagoo', request_id: 'test-uuid-123', interactive_search: true) }
  let(:results) { Search::InternalSearchResult.new([], meta) }
  let(:meta) do
    {
      'interactive_search' => {
        'query' => 'flimflammagoo',
        'answers' => [
          { 'question' => 'Which of these best describes the product?', 'answer' => 'Standard jam / jelly / marmalade / fruit spread for general consumption' },
          { 'question' => 'What type of fruit is the spread primarily made from?', 'answer' => 'Citrus fruit' },
        ],
      },
    }
  end

  describe 'inset text' do
    it { is_expected.to have_css('.govuk-inset-text', text: 'These are the details you supplied:') }
    it { is_expected.to have_css('.govuk-inset-text', text: 'Initial search term') }
    it { is_expected.to have_css('.govuk-inset-text', text: 'flimflammagoo') }
    it { is_expected.to have_css('.govuk-inset-text', text: 'Which of these best describes the product?') }
    it { is_expected.to have_css('.govuk-inset-text', text: 'Standard jam / jelly / marmalade / fruit spread for general consumption') }
    it { is_expected.to have_css('button', text: 'Copy results to clipboard') }
    it { is_expected.to have_css('button[type="button"][data-action="copy-search-details#copy"][data-copy-search-details-target="button"]') }
    it { is_expected.to have_css('[data-copy-search-details-target="content"]') }
  end

  describe 'error guidance' do
    it { is_expected.to have_text('Something about what you searched for has caused a problem') }
    it { is_expected.to have_css('h2', text: 'What information is needed?') }
    it { is_expected.to have_text('the type of product') }
    it { is_expected.to have_text('what the product is used for') }
    it { is_expected.to have_css('h2', text: 'Where can I find this information?') }
    it { is_expected.to have_text('invoice or other billing documents') }
  end

  describe 'next steps' do
    it { is_expected.to have_css('h2', text: 'Next steps') }
    it { is_expected.to have_text('Check your answers and start your search again.') }
    it { is_expected.to have_link('Start search again', href: find_commodity_path) }
    it { is_expected.to have_link('Cancel', href: find_commodity_path) }

    context 'when webchat is enabled' do
      before { Flipper.enable(:webchat) }

      it { is_expected.to have_css('p.govuk-body', text: 'Webchat: Ask HMRC online') }
      it { is_expected.to have_css('p.govuk-body', text: 'Email: classification.enquiries@hmrc.gov.uk') }
      it { is_expected.to have_link('Ask HMRC online') }
      it { is_expected.to have_link('classification.enquiries@hmrc.gov.uk', href: 'mailto:classification.enquiries@hmrc.gov.uk') }
    end

    context 'when webchat is disabled' do
      it { is_expected.not_to have_link('Ask HMRC online') }
      it { is_expected.to have_css('p.govuk-body', text: 'Email: classification.enquiries@hmrc.gov.uk') }
      it { is_expected.to have_link('classification.enquiries@hmrc.gov.uk', href: 'mailto:classification.enquiries@hmrc.gov.uk') }
    end
  end

  describe 'sidebar' do
    it { is_expected.to have_text('Help and guidance') }
    it { is_expected.to have_link('Classifying your goods') }
    it { is_expected.to have_link('How to use quotas') }
    it { is_expected.to have_link('How to value your goods for import or export') }
  end

  describe 'alternative search cards' do
    it { is_expected.to have_css('h2', text: 'Other ways to search for a commodity') }
    it { is_expected.to have_link('Keyword or commodity code') }
    it { is_expected.to have_link('Goods classifications') }
    it { is_expected.to have_link('A-Z product index') }
  end
end
