require 'spec_helper'

RSpec.describe 'Homepage news visibility', :aggregate_failures, type: :request do
  include_context 'with news updates stubbed'

  let(:page) { Capybara.string(response.body) }
  let(:news_items) do
    [attributes_for(:news_item, title: 'News-managed homepage notice', precis: 'Current editorial guidance.')]
  end

  %w[uk xi].product([true, false], [true, false]).each do |service, ai_enabled, parcel_enabled|
    context "with #{service}, AI #{ai_enabled} and parcel layout #{parcel_enabled}" do
      before do
        TEST_FLAGSMITH_CLIENT.set_flag(:interactive_search, ai_enabled)
        TEST_FLAGSMITH_CLIENT.set_flag(:parcel_gift_journey, parcel_enabled)
        stub_api_request("news/items?service=#{service}&target=home&per_page=1", backend: 'uk')
          .to_return jsonapi_response(:news_item, news_items)
      end

      it 'keeps editorial news independent of the layout and search flags' do
        get "/#{service}/find_commodity"

        expect(response).to have_http_status(:ok)
        expect(page).to have_css('.latest-news-banner h2', text: 'News-managed homepage notice')
        expect(page).to have_css('.latest-news-banner', text: 'Current editorial guidance.', count: 1)
      end

      context 'when the news integration returns no homepage notice' do
        let(:news_items) { [] }

        it 'omits editorial news when none is published' do
          get "/#{service}/find_commodity"

          expect(response).to have_http_status(:ok)
          expect(page).not_to have_css('.latest-news-banner')
        end
      end
    end
  end
end
