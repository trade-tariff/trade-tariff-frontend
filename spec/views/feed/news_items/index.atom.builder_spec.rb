require 'spec_helper'

RSpec.describe 'feed/news_items/index.atom.builder', type: :view do
  subject { render }

  before { assign :news_items, news_items }

  context 'with a single news item' do
    let(:news_items) { [news_item] }

    let(:news_item) do
      build(
        :news_item,
        id: '1',
        start_date: Date.parse('2022-01-05'),
        end_date: Date.parse('2022-01-06'),
        title: 'Are you importing goods into Northern Ireland?',
        content: 'Tempus fugit',
      )
    end

    it { is_expected.to have_css 'feed title', text: 'Online Trade Tariff News Items' }
    it { is_expected.to have_css 'feed entry id', text: 'tag:test.host,2005:NewsItem/1' }
    it { is_expected.to have_css 'feed entry title', text: 'Are you importing goods into Northern Ireland?' }
    it { is_expected.to have_css 'feed entry start_date', text: '05 Jan 2022' }
    it { is_expected.to have_css 'feed entry end_date', text: '06 Jan 2022' }
    it { is_expected.to have_css 'feed entry content', text: 'Tempus fugit' }
    it { is_expected.to have_css 'feed entry uk', text: 'true' }
    it { is_expected.to have_css 'feed entry xi', text: 'true' }
    it { is_expected.to have_css 'feed entry home_page', text: 'http://test.host/find_commodity' }
    it { is_expected.to have_css 'feed entry updates_page', text: 'http://test.host/news' }
  end

  context 'with no news items' do
    let(:news_items) { [] }

    it { is_expected.to have_css 'feed title', text: 'Online Trade Tariff News Items' }
    it { is_expected.not_to have_css 'feed entry' }
  end
end
