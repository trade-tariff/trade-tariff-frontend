require 'spec_helper'

RSpec.describe 'news_items/index.html.erb', type: :view do
  subject { render }

  before { assign :news_items, news_items }

  let(:news_items) { build_list :news_item, 3, content: "[[SERVICE_NAME]]\n\nFirst para" }
  let(:date_format) { /\d\d? [A-Z][a-z]{2} [12]\d{3}/ }

  it { is_expected.to have_css 'section.news-items' }
  it { is_expected.to have_css 'article .news-item__date', text: date_format, count: 3 }
  it { is_expected.to have_css 'section.news-items article.news-item', count: 3 }
  it { is_expected.to have_css 'section article h2', count: 3 }
  it { is_expected.to have_css 'section article .tariff-markdown p', count: 3 }
  it { is_expected.to have_css '.news-item p', text: /#{I18n.t('title.service_name.uk')}/ }
  it { is_expected.to have_link 'Show more ...', href: %r{/news/\d+} }

  context 'with single paragraph news items' do
    let(:news_items) { build_list :news_item, 2, content: 'Single paragraph' }

    it { is_expected.to have_css 'article .tariff-markdown p', count: 2 }
    it { is_expected.not_to have_link 'Show more ...' }
  end

  context 'with no news items' do
    let(:news_items) { [] }

    it { is_expected.not_to have_css 'article .tariff-markdown p' }
    it { is_expected.to have_css 'section p', text: /no updates/ }
  end
end
