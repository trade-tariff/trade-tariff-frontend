require 'spec_helper'

RSpec.describe NewsItemsController, type: :request do
  subject { make_request && response }

  let(:news_item) { build :news_item }

  describe 'GET #index' do
    before do
      allow(News::Year).to receive(:all).and_return build_list(:news_year, 2)
      allow(News::Collection).to receive(:all).and_return build_list(:news_collection, 2)
    end

    let(:page) { 1 }

    let :paginated do
      Kaminari.paginate_array([news_item], total_count: 10).page(page).per(2)
    end

    context 'without page specified' do
      before do
        allow(News::Item).to receive(:updates_page).with(no_args)
                                                   .and_return(paginated)
      end

      let(:make_request) { get news_items_path }

      it { is_expected.to have_http_status :ok }
      it { is_expected.to have_attributes content_type: %r{text/html} }
    end

    context 'with later page' do
      before do
        allow(News::Item).to receive(:updates_page).with(page: '2')
                                                   .and_return(paginated)
      end

      let(:make_request) { get news_items_path(page: 2) }

      it { is_expected.to have_http_status :ok }
    end
  end

  describe 'GET #show' do
    before do
      allow(News::Item).to receive(:find)
                         .with(news_item.slug)
                         .and_return news_item

      allow(News::Item).to receive(:updates_page)
                           .with(collection_id: news_item.collections.first&.id)
                           .and_return([])
    end

    let(:make_request) { get news_item_path news_item }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
