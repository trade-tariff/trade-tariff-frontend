require 'spec_helper'

RSpec.describe 'news_items/show', type: :view do
  subject { render }

  before do
    assign :news_item, news_item
    assign :news_collection, news_item.collections.first
  end

  let(:news_item) { build :news_item, :with_precis, content: 'Welcome to [[SERVICE_NAME]]' }
  let(:expected_date) { news_item.start_date.to_formatted_s :long }

  it { is_expected.to have_css '.govuk-grid-row .govuk-grid-column-two-thirds', count: 2 }
  it { is_expected.to have_css '.govuk-grid-row .govuk-grid-column-one-third', count: 1 }
  it { is_expected.to have_css 'article.news-item' }
  it { is_expected.to have_css 'h1', text: news_item.title }
  it { is_expected.to have_css '.tariff-markdown--with-all-lead-paragraph p' }

  it { is_expected.to have_css '.gem-c-metadata dl dt', text: /from/i }
  it { is_expected.to have_css '.gem-c-metadata dl dt', text: /published/i }
  it { is_expected.to have_css '.gem-c-metadata dl dd', count: 2 }

  it { is_expected.not_to have_css '#contents' }

  it { is_expected.to have_css 'article .tariff-markdown p' }
  it { is_expected.to have_css 'p', text: /Welcome to #{I18n.t('title.service_name.uk')}/ }

  context 'without precis' do
    let(:news_item) { build :news_item, content: "First\n\nSecond" }

    it { is_expected.not_to have_css '.tariff-markdown--with-all-lead-paragraph p' }
    it { is_expected.to have_css '.tariff-markdown p', text: 'First' }
    it { is_expected.to have_css '.tariff-markdown p', text: 'Second' }
  end

  context 'with subheadings' do
    let(:news_item) { build :news_item, :with_subheadings }

    it { is_expected.to have_css '#contents ol.gem-c-contents-list__list' }
    it { is_expected.to have_css '#contents li a', count: news_item.subheadings.length }
    it { is_expected.to have_link news_item.subheadings.first, href: '#second-heading' }
  end
end
