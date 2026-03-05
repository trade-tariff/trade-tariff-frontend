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

  describe 'help details components' do
    it { is_expected.to have_css('.govuk-details__summary-text', text: 'What are keyword, commodity code and guided searches?') }
    it { is_expected.to have_css('.govuk-details__summary-text', text: 'Tips for using keyword or commodity code search') }
    it { is_expected.to have_css('.govuk-details__summary-text', text: 'Tips for using guided search') }
  end

  describe 'devolved nations banner' do
    it { is_expected.to have_css('.govuk-notification-banner__title', text: 'Devolved nations') }
  end

  describe 'browse/A-Z cards' do
    it { is_expected.to have_css('.govuk-card') }
    it { is_expected.to have_link('Browse the goods classification') }
    it { is_expected.to have_link('A-Z of classified goods') }
  end
end
