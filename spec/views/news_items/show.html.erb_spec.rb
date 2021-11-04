require 'spec_helper'

RSpec.describe 'news_items/show.html.erb', type: :view do
  subject { render }

  before { assign :news_item, news_item }

  let(:news_item) { build :news_item }
  let(:expected_date) { news_item.start_date.to_formatted_s :long }

  it { is_expected.to have_css 'article.news-item' }
  it { is_expected.to have_css 'article h2', text: news_item.title }
  it { is_expected.to have_css 'article h3', text: /published.*#{expected_date}/i }
  it { is_expected.to have_css 'article .tariff-markdown p' }
end
