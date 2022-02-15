require 'spec_helper'

RSpec.describe 'find_commodities/show', type: :view do
  subject { render }

  before { assign :search, search }

  let(:now) { Time.zone.today }
  let(:q) { nil }
  let(:search) { Search.new q: q, 'day' => now.day, 'month' => now.month, 'year' => now.year }

  describe 'header' do
    it { is_expected.to have_css 'header h1', text: /commodity codes, import duties/ }
  end

  describe 'search form' do
    it { is_expected.to have_css 'form input[name="q"]' }
    it { is_expected.to have_css 'form details .govuk-details__text' }

    shared_examples 'a populated date input' do
      it { is_expected.to have_css %(.govuk-details__text input[name="day"][value="#{now.day}"]) }
      it { is_expected.to have_css %(.govuk-details__text input[name="month"][value="#{now.month}"]) }
      it { is_expected.to have_css %(.govuk-details__text input[name="year"][value="#{now.year}"]) }
    end

    context 'with default date' do
      it_behaves_like 'a populated date input'
    end

    context 'with selected date' do
      let(:now) { 3.days.ago }

      it_behaves_like 'a populated date input'
    end
  end

  describe 'STW links' do
    it { is_expected.to have_css 'h2', text: 'Advance tariff rulings' }
    it { is_expected.to have_css 'h2', text: 'Check how to import or export goods' }
  end

  describe 'latest news' do
    context 'when published for home page' do
      before { assign :latest_news, build(:news_item) }

      it { is_expected.to have_css '.latest-news-banner', count: 1 }
    end

    context 'when not published for home page' do
      it { is_expected.not_to have_css '.latest-news-banner' }
    end
  end
end
