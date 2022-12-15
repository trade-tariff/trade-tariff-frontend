RSpec.shared_context 'with latest news stubbed' do
  before { allow(News::Item).to receive(:latest_for_home_page).and_return build(:news_item) }
end

RSpec.shared_context 'with news updates stubbed' do
  before { allow(News::Item).to receive(:updates_page).and_return build_list(:news_item, 3) }
end
