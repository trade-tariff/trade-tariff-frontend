require 'spec_helper'

RSpec.describe 'news_items/latest_news', type: :view do
  subject { render 'news_items/latest_news', news_item: news_item }

  let(:news_item) { build :news_item, content: "[[SERVICE_NAME]]\n\nFirst para" }

  it { is_expected.to have_css '.latest-news-banner.govuk-notification-banner' }
  it { is_expected.to have_css '.latest-news-banner h2', text: news_item.title }
  it { is_expected.to have_css '.latest-news-banner .tariff-markdown p' }
  it { is_expected.to have_css '.latest-news-banner p', text: /#{I18n.t('title.service_name.uk')}/ }
  it { is_expected.to have_link 'Show more ...', href: news_item_path(news_item) }
end
