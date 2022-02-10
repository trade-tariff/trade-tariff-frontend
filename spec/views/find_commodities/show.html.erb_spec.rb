require 'spec_helper'

RSpec.describe 'find_commodities/show', type: :view do
  subject { render }

  before { assign :search, search }

  let(:as_of) { Time.zone.today }
  let(:q) { nil }
  let(:search) { Search.new q: q, as_of: as_of }

  describe 'header' do
    it { is_expected.to have_css 'header h1', text: /commodity codes, import duties/ }
  end

  describe 'search form' do
    it { is_expected.to have_css 'form input[name="q"]' }
    it { is_expected.to have_css 'form details .govuk-details__text' }

    shared_examples 'a populated date input' do
      it { is_expected.to have_css %(.govuk-details__text input[name="day"][value="#{as_of.day}"]) }
      it { is_expected.to have_css %(.govuk-details__text input[name="month"][value="#{as_of.month}"]) }
      it { is_expected.to have_css %(.govuk-details__text input[name="year"][value="#{as_of.year}"]) }
    end

    context 'with default date' do
      it_behaves_like 'a populated date input'
    end

    context 'with selected date' do
      let(:as_of) { 3.days.ago }

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
