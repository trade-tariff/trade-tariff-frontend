require 'spec_helper'

RSpec.describe 'news_items/index', type: :view do
  subject { render }

  before { assign :news_items, paginated_news_items }

  let(:news_items) { build_list :news_item, 3, content: "[[SERVICE_NAME]]\n\nFirst para" }
  let(:date_format) { /\d\d? [A-Z][a-z]{2} [12]\d{3}/ }

  let :paginated_news_items do
    Kaminari.paginate_array(news_items, total_count: news_items.length).page(1).per(10)
  end

  it { is_expected.to have_css 'article.news-item' }
  it { is_expected.to have_css 'article .tariff-body-subtext', text: date_format }
  it { is_expected.to have_css 'article .tariff-body-subtext', text: news_items.first.collections.first.name }
  it { is_expected.to have_css 'article h2', count: 3 }
  it { is_expected.to have_link news_items.first.title, href: %r{/news/\d+} }
  it { is_expected.to have_css 'article .tariff-markdown p', count: 3 }
  it { is_expected.to have_css '.news-item p', text: /#{I18n.t('title.service_name.uk')}/ }
  it { is_expected.not_to have_css '.pagination' }

  context 'with multiple pages available' do
    let :paginated_news_items do
      Kaminari.paginate_array(news_items, total_count: 200).page(1).per(10)
    end

    it { is_expected.to have_css '.pagination' }
  end

  context 'with single paragraph news items' do
    let(:news_items) { build_list :news_item, 2, content: 'Single paragraph' }

    it { is_expected.to have_css 'article .tariff-markdown p', count: 2 }
    it { is_expected.not_to have_link 'Show more ...' }
  end

  context 'with no news items' do
    let(:news_items) { [] }

    it { is_expected.not_to have_css 'article .tariff-markdown p' }
    it { is_expected.to have_css 'p', text: /no updates/ }
  end
end
