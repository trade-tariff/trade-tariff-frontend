require 'spec_helper'

RSpec.describe 'news_items/show', type: :view do
  subject { render }

  before { assign :news_item, news_item }

  let(:news_item) { build :news_item, content: 'Welcome to [[SERVICE_NAME]]' }
  let(:expected_date) { news_item.start_date.to_formatted_s :long }

  it { is_expected.to have_css 'article.news-item' }
  it { is_expected.to have_css 'article h2', text: news_item.title }
  it { is_expected.to have_css 'article h3', text: /published.*#{expected_date}/i }
  it { is_expected.to have_css 'article .tariff-markdown p', text: /Welcome to/, count: 1 }
  it { is_expected.to have_css 'p', text: /Welcome to #{I18n.t('title.service_name.uk')}/ }

  context 'with precis' do
    let :news_item do
      build :news_item, precis: 'precis para', content: 'content para'
    end

    it { is_expected.to have_css 'article .tariff-markdown p', text: 'precis para' }
    it { is_expected.to have_css 'article .tariff-markdown p', text: 'content para' }
  end
end
