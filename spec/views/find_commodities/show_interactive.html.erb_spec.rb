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
    it { is_expected.to have_css('textarea#guided_q[name="q"]') }
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
    it { is_expected.to have_text('When are you planning to trade the products?') }
  end

  describe 'submit button' do
    it { is_expected.to have_css('input[type="submit"][value="Search for a commodity"]') }
  end
end
