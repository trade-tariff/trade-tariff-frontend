require 'spec_helper'

RSpec.describe 'news_items/show.html.erb', type: :view do
  subject { render }

  before { assign :news_item, news_item }

  let(:news_item) { build :news_item, content: 'Welcome to [[SERVICE_NAME]]' }
  let(:expected_date) { news_item.start_date.to_formatted_s :long }

  it { is_expected.to have_css 'article.news-item' }
  it { is_expected.to have_css 'article h2', text: news_item.title }
  it { is_expected.to have_css 'article h3', text: /published.*#{expected_date}/i }
  it { is_expected.to have_css 'article .tariff-markdown p' }
  it { is_expected.to have_css 'p', text: /Welcome to #{I18n.t('title.service_name.uk')}/ }
end
