require 'spec_helper'

RSpec.describe 'news_items/recent_news', type: :view do
  subject { render 'news_items/recent_news', news_items: }

  let(:news_items) { build_list :news_item, 3 }

  it { is_expected.to have_css 'h2', text: 'Latest news' }
  it { is_expected.to have_link 'See all latest news', href: news_items_path }

  it { is_expected.to have_css 'article.news-item p.govuk-body-s a', count: 3 }
  it { is_expected.to have_css 'article.news-item p.tariff-body-subtext a', count: 3 }
end
