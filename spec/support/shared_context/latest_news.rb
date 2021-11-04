RSpec.shared_context 'with latest news stubbed' do
  before { allow(NewsItem).to receive(:latest_for_home_page).and_return latest_news }

  let(:latest_news) { build :news_item }
end
