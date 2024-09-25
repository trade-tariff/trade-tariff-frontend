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
end
