require 'spec_helper'

RSpec.describe 'sections/index.html.erb', type: :view do
  subject { render }

  before do
    assign :latest_news, latest_news
    assign :sections, []
    assign :tariff_updates, []
  end

  let(:latest_news) { build :news_item }

  it { is_expected.to have_css '.latest-news-banner', count: 1 }

  context 'when no news items published for home page' do
    let(:latest_news) { nil }

    it { is_expected.not_to have_css '.latest-news-banner' }
  end
end
