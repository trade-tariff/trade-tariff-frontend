require 'spec_helper'

RSpec.describe NewsItemsController, type: :request do
  subject { make_request && response }

  let(:news_item) { build :news_item }

  describe 'GET #index' do
    before { allow(NewsItem).to receive(:updates_page).and_return [news_item] }

    let(:make_request) { get news_items_path }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end

  describe 'GET #show' do
    before do
      allow(NewsItem).to receive(:find)
                         .with(news_item.id.to_s)
                         .and_return news_item
    end

    let(:make_request) { get news_item_path news_item.id }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
