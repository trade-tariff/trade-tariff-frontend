require 'spec_helper'

RSpec.describe Feed::NewsItemsController, type: :request, vcr: { cassette_name: 'news_items#updates' } do
  describe 'GET #index' do
    subject(:do_request) { get(feed_news_items_path) && response }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: 'application/atom+xml; charset=utf-8' }
  end
end
