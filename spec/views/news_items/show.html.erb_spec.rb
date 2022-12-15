require 'spec_helper'

RSpec.describe 'news_items/show', type: :view do
  subject { render }

  before do
    assign :news_item, news_item
    assign :news_collection, news_collection
    assign :collection_items, build_list(:news_item, 3)
  end

  let(:news_item) { build :news_item, :with_precis, content: 'Welcome to [[SERVICE_NAME]]' }
  let(:news_collection) { news_item.collections.first }
  let(:expected_date) { news_item.start_date.to_formatted_s :long }

  it { is_expected.to have_css '.govuk-grid-row .govuk-grid-column-two-thirds', count: 2 }
  it { is_expected.to have_css '.govuk-grid-row .govuk-grid-column-one-third', count: 1 }
  it { is_expected.to have_css 'article.news-item' }
  it { is_expected.to have_css 'h1', text: news_item.title }
  it { is_expected.to have_css '.tariff-markdown--with-all-lead-paragraph p' }

  it { is_expected.to have_css '.gem-c-metadata dl dt', text: /from/i }
  it { is_expected.to have_css '.gem-c-metadata dl dt', text: /published/i }
  it { is_expected.to have_css '.gem-c-metadata dl dd', count: 2 }
  it { is_expected.to have_css '.gem-c-print-link button' }

  it { is_expected.not_to have_css '#contents' }

  it { is_expected.to have_css 'article .tariff-markdown p' }
  it { is_expected.to have_css 'p', text: /Welcome to #{I18n.t('title.service_name.uk')}/ }
  it { is_expected.to have_css 'p', text: news_collection.description }

  it { is_expected.to have_css '.govuk-grid-column-one-third h3', text: /latest content/i }
  it { is_expected.to have_css '.govuk-grid-column-one-third li a', count: 3 }
  it { is_expected.to have_css '.govuk-grid-column-one-third h3', text: 'Collection' }
  it { is_expected.to have_link 'Back to top' }
  it { is_expected.to have_css '.govuk-grid-column-one-third p a', text: news_collection.name }

  context 'without precis' do
    let(:news_item) { build :news_item, content: "First\n\nSecond", precis: '' }

    it { is_expected.to have_css '.tariff-markdown--with-all-lead-paragraph p', text: 'First' }
    it { is_expected.not_to have_css '.news-item__content.tariff-markdown p', text: 'First' }
    it { is_expected.to have_css '.news-item__content.tariff-markdown p', text: 'Second' }
  end

  context 'with subheadings' do
    let(:news_item) { build :news_item, :with_subheadings }

    it { is_expected.to have_css '#contents ol.gem-c-contents-list__list' }
    it { is_expected.to have_css '#contents li a', count: news_item.subheadings.length }
    it { is_expected.to have_link news_item.subheadings.first, href: '#second-heading' }
  end
end
