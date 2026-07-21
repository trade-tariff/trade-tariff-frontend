require 'spec_helper'

RSpec.describe 'find_commodities/show_interactive', type: :view do
  subject { render }

  before do
    assign :search, search
    assign :recent_stories, build_list(:news_item, 3)
  end

  let(:search) { build(:search, :with_search_date, q: '0101300000', search_date: Time.zone.today) }

  describe 'header' do
    it { is_expected.to have_css 'header h1', text: /commodity codes, import duties/ }
  end

  describe 'search type radio buttons' do
    it { is_expected.to have_css('input[type="radio"][value="keyword"]') }
    it { is_expected.to have_css('input[type="radio"][value="guided"]') }
    it { is_expected.to have_text('Keyword or commodity code search') }
    it { is_expected.to have_text('Guided search') }
  end

  describe 'conditional reveal content' do
    it { is_expected.to have_css('textarea#search-q-field') }
    it { is_expected.to have_text('Describe the products you are trading') }
    it { is_expected.to have_text('Enter the name of the products or commodity code') }
    it { is_expected.to have_text('For example, tomatoes or 1234 5678 90') }
  end

  describe 'help details components' do
    it { is_expected.to have_css('.govuk-details__summary-text', text: 'What are keyword, commodity code and guided searches?') }
    it { is_expected.to have_css('.govuk-details__summary-text', text: 'Tips for using keyword or commodity code search') }
    it { is_expected.to have_css('.govuk-details__summary-text', text: 'Tips for using guided search') }
  end

  describe 'keyword tips content' do
    it { is_expected.to have_css('.special-numbered-list') }
    it { is_expected.to have_text('Steps for searching the tariff') }
  end

  describe 'guided search tips content' do
    it 'renders the approved guidance and steps', :aggregate_failures do
      render
      guided_tips = Capybara.string(rendered).find('#conditional-guided', visible: :all)

      expect(guided_tips).to have_css('h3', text: 'Steps for using guided search')
      expect(guided_tips).to have_css('.special-numbered-list li', count: 3)
      expect(guided_tips).to have_text('Do not enter any personal or sensitive information in your search queries.')
      expect(guided_tips).to have_link(
        'Tax and customs for goods sent from abroad: Tax and duty - GOV.UK',
        href: 'https://www.gov.uk/goods-sent-from-abroad/tax-and-duty',
      )
    end
  end

  describe 'hero spimm banner' do
    it { is_expected.to have_css('.govuk-notification-banner', text: /Importing goods into Northern Ireland/) }
    it { is_expected.to have_link('Check eligibility') }
  end

  describe 'other ways to search' do
    it { is_expected.to have_css('h2', text: 'Other ways to search for a commodity') }
    it { is_expected.to have_link('Keyword or commodity code') }
    it { is_expected.to have_link('Goods classifications') }
    it { is_expected.to have_link('A-Z product index') }
    it { is_expected.to have_text('Browse the goods classification') }
    it { is_expected.to have_text('Look for your product in the A-Z') }
  end

  describe 'fieldset legend' do
    it { is_expected.to have_css('legend h2', text: 'What type of search are you doing?') }
  end

  describe 'date picker' do
    it { is_expected.to have_text('When are you planning to trade the goods?') }

    context 'with an invalid date flag' do
      let(:search) do
        build(:search, :with_search_date, q: '0101300000', search_date: Time.zone.today).tap do |s|
          s.errors.add(:as_of, 'You must enter a valid date')
        end
      end

      before do
        view.params[:invalid_date] = 'true'
        view.params[:day] = '22'
        view.params[:month] = '0'
        view.params[:year] = '2026'
      end

      it { is_expected.to have_css('.govuk-error-summary', text: 'You must enter a valid date') }
      it { is_expected.to have_css('.govuk-error-summary a[href="#search-as-of-field-error"]', text: 'You must enter a valid date') }
      it { is_expected.to have_css('#search-as-of-field-error') }
      it { is_expected.to have_css('.govuk-form-group--error #search-as-of-field-error.govuk-input--error') }
      it { is_expected.to have_css('input[name="search[as_of(3i)]"]') }
      it { is_expected.to have_css('input[name="search[as_of(2i)]"]') }
      it { is_expected.to have_css('input[name="search[as_of(1i)]"]') }
    end

    context 'with stale invalid_date params but no date error' do
      before do
        view.params[:invalid_date] = 'true'
        view.params[:day] = '22'
        view.params[:month] = '7'
        view.params[:year] = '2026'
      end

      it { is_expected.not_to have_css('.govuk-error-summary', text: 'You must enter a valid date') }
      it { is_expected.not_to have_css('.govuk-form-group--error #search-as-of-field-error.govuk-input--error') }
    end
  end

  describe 'submit button' do
    it { is_expected.to have_css('input[type="submit"][value="Search for a commodity"]') }

    context 'when invalid date params are present' do
      before do
        view.params[:invalid_date] = 'true'
        view.params[:day] = '22'
        view.params[:month] = '0'
        view.params[:year] = '2026'
      end

      it { is_expected.to have_css('form#new_search[action="/search"]') }
    end
  end

  describe 'guided search loading state' do
    it { is_expected.to have_css('[data-guided-search-validation-loading-page]') }
    it { is_expected.not_to have_css('[data-guided-search-validation-target="thinking"]', visible: :all) }

    context 'when the guided search has validation errors' do
      let(:search) do
        build(:search, :with_search_date, q: '', search_date: Time.zone.today).tap do |search|
          search.errors.add(:q, 'Enter a search term')
        end
      end

      it { is_expected.to have_css('.govuk-error-summary', text: 'Enter a search term') }
      it { is_expected.to have_css('.govuk-error-message#search-q-error', text: 'Enter a search term') }
      it { is_expected.to have_css('label[for="search-q-field-error"]') }
      it { is_expected.to have_css('.govuk-error-summary a[href="#search-q-field-error"]', text: 'Enter a search term') }
      it { is_expected.not_to have_css('[data-guided-search-validation-target="thinking"]', visible: :all) }
    end
  end
end
