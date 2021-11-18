require 'spec_helper'

RSpec.describe 'news_items/latest_news.html.erb', type: :view do
  subject { render 'news_items/latest_news', news_item: news_item }

  let(:news_item) { build :news_item }

  it { is_expected.to have_css '.latest-news-banner.govuk-notification-banner' }
  it { is_expected.to have_css '.latest-news-banner h2', text: news_item.title }
  it { is_expected.to have_css '.latest-news-banner .tariff-markdown p' }
  it { is_expected.to have_link 'Show more ...', href: news_item_path(news_item) }
end
