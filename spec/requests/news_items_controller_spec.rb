require 'spec_helper'

RSpec.describe NewsItemsController, type: :request do
  subject { make_request && response }

  let(:news_item) { build :news_item }

  describe 'GET #index' do
    before do
      allow(News::Item).to receive(:updates_page).with(page, year: nil)
                                                 .and_return(paginated)

      allow(News::Year).to receive(:all).and_return build_list(:news_year, 2)
    end

    let(:page) { 1 }

    let :paginated do
      Kaminari.paginate_array([news_item], total_count: 10).page(page).per(2)
    end

    context 'without page specified' do
      let(:make_request) { get news_items_path }

      it { is_expected.to have_http_status :ok }
      it { is_expected.to have_attributes content_type: %r{text/html} }
    end

    context 'with later page' do
      let(:page) { 2 }
      let(:make_request) { get news_items_path(page: 2) }

      it { is_expected.to have_http_status :ok }
    end
  end

  describe 'GET #show' do
    before do
      allow(News::Item).to receive(:find)
                         .with(news_item.id.to_s)
                         .and_return news_item
    end

    let(:make_request) { get news_item_path news_item.id }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
