require 'spec_helper'

RSpec.describe 'news_items/index', type: :view do
  subject { render }

  before do
    assign :news_items, paginated_news_items
    assign :news_years, news_years
    assign :news_collections, news_collections

    allow(view).to receive(:news_index_params).and_return({})
  end

  let(:news_items) { build_list :news_item, 3, content: "[[SERVICE_NAME]]\n\nFirst para" }
  let(:news_years) { build_list :news_year, 3 }
  let(:news_collections) { build_list :news_collection, 2 }
  let(:date_format) { /\d\d? [A-Z][a-z]{2} [12]\d{3}/ }

  let :paginated_news_items do
    Kaminari.paginate_array(news_items, total_count: news_items.length).page(1).per(10)
  end

  it { is_expected.to have_css 'article.news-item' }
  it { is_expected.to have_css 'article .tariff-body-subtext', text: date_format }
  it { is_expected.to have_css 'article .tariff-body-subtext', text: news_items.first.collections.first.name }
  it { is_expected.to have_css 'article h2', count: 3 }
  it { is_expected.to have_css '.news-items > h2', text: 'All collections' }
  it { is_expected.to have_link news_items.first.title, href: news_item_path(news_items.first) }
  it { is_expected.to have_css 'article .tariff-markdown p', count: 3 }
  it { is_expected.to have_css '.news-item p', text: /#{I18n.t('title.service_name.uk')}/ }
  it { is_expected.not_to have_css '.pagination' }

  it { is_expected.to have_css 'ul#news-year-filter li', count: 4 }
  it { is_expected.to have_css 'ul#news-year-filter li a', count: 3 }
  it { is_expected.not_to have_css 'ul#news-year-filter li a', text: 'All years' }

  it { is_expected.to have_css 'ul#news-collection-filter li', count: 3 }
  it { is_expected.to have_css 'ul#news-collection-filter li a', count: 2 }
  it { is_expected.not_to have_css 'ul#news-collection-filter li a', text: 'All collections' }

  context 'with multiple pages available' do
    let :paginated_news_items do
      Kaminari.paginate_array(news_items, total_count: 200).page(1).per(10)
    end

    it { is_expected.to have_css '.govuk-pagination' }
  end

  context 'with single paragraph news items' do
    let(:news_items) { build_list :news_item, 2, content: 'Single paragraph' }

    it { is_expected.to have_css 'article .tariff-markdown p', count: 2 }
    it { is_expected.not_to have_link 'Show more ...' }
  end

  context 'with safe html in title' do
    let(:news_items) { build_list :news_item, 2, :with_safe_html }

    it { is_expected.to have_css 'article h2 a abbr' }
  end

  context 'with unsafe html in title' do
    let(:news_items) { build_list :news_item, 2, :with_unsafe_html }

    it { is_expected.not_to have_css 'article h2 a script' }
  end

  context 'with no news items' do
    let(:news_items) { [] }

    it { is_expected.not_to have_css 'article .tariff-markdown p' }
    it { is_expected.to have_css 'p', text: /no updates/ }
  end

  context 'when filtering by year' do
    before { assign :filter_year, news_years.second.year }

    it { is_expected.to have_css 'ul#news-year-filter li', count: 4 }
    it { is_expected.to have_css 'ul#news-year-filter li a', count: 3 }
    it { is_expected.to have_css 'ul#news-year-filter li a', text: 'All years' }
    it { is_expected.not_to have_css 'ul#news-year-filter li a', text: news_years.second.year.to_s }
  end

  context 'when filtering by collection' do
    before { assign :filter_collection, news_collections.first }

    it { is_expected.to have_css 'ul#news-collection-filter li', count: 3 }
    it { is_expected.to have_css 'ul#news-collection-filter li a', count: 2 }
    it { is_expected.to have_css 'ul#news-collection-filter li a', text: 'All collections' }
    it { is_expected.not_to have_css 'ul#news-collection-filter li a', text: news_collections.first.name }

    it { is_expected.to have_css '.news-items > h2', text: news_collections.first.name }
  end
end
