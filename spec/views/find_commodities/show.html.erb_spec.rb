require 'spec_helper'

RSpec.describe 'find_commodities/show', type: :view do
  subject { render }

  before do
    assign :search, search
    assign :recent_stories, build_list(:news_item, 3)
  end

  let(:search_date) { Time.zone.today }
  let(:q) { nil }

  let(:search) { build(:search, :with_search_date, q: '0101300000', search_date:) }

  describe 'header' do
    it { is_expected.to have_css 'header h1', text: /commodity codes, import duties/ }
  end

  describe 'hero story' do
    context 'when published for home page' do
      before { assign :hero_story, build(:news_item) }

      it { is_expected.to have_css '.latest-news-banner', count: 1 }
    end

    context 'when not published for home page' do
      it { is_expected.not_to have_css '.latest-news-banner' }
    end
  end

  describe 'recent news stories' do
    it { is_expected.to have_css 'h2', text: 'Latest news' }
  end

  describe 'search tips' do
    it { is_expected.to have_css('.govuk-details__summary-text', text: 'Tips on searching for products') }
  end

  context 'with AI-assisted search enabled' do
    before do
      assign :ai_search_enabled, true
      assign :search_mode, 'guided'
    end

    it { is_expected.to have_css('#ai-search-tab', text: 'AI-assisted search') }
    it { is_expected.to have_css('#keyword-search-tab', exact_text: 'Code or keyword search') }
    it { is_expected.to have_css('[data-guided-search-validation-loading-page]') }

    context 'with invalid date and query answers' do
      before do
        search.errors.add(:as_of, 'Date of trade must be a real date')
        search.errors.add(:q, 'Enter a search term')
      end

      it 'keeps errors associated with the affected fields', :aggregate_failures do
        render
        expect(rendered).to have_css('.govuk-error-summary', count: 1)
        expect(rendered).to have_css('.govuk-error-summary a[href="#search-as-of-field-error"]')
        expect(rendered).to have_css('details#find-commodity-date[open]')
        expect(rendered).to have_css('.govuk-error-summary a[href="#search-q-field-error"]')
        expect(rendered).to have_css('label[for="search-q-field-error"]')
        expect(rendered).to have_css('.govuk-error-message#search-q-error', text: 'Enter a search term')
      end
    end
  end
end
