require 'spec_helper'

RSpec.describe 'Search service navigation', :aggregate_failures, type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  around do |example|
    travel_to(Time.utc(2026, 10, 21, 12)) { example.run }
  end

  before do
    stub_const('ENV', ENV.to_h.except('HYBRID_SEARCH'))
    allow(GeographicalArea).to receive(:all).and_return([])
  end

  def stub_searches(hybrid:)
    %w[uk xi].each do |service|
      TradeTariffFrontend::ServiceChooser.with_source(service) do
        response = if hybrid
                     { status: 200, body: { data: [] }.to_json, headers: { 'content-type' => 'application/json' } }
                   else
                     jsonapi_response(:search, {
                       type: 'fuzzy_match',
                       goods_nomenclature_match: { chapters: [], headings: [], commodities: [], sections: [] },
                       reference_match: { chapters: [], headings: [], commodities: [], sections: [] },
                     })
                   end
        stub_api_request('search', :post, internal: hybrid).to_return(response)
      end
    end
  end

  def switch_destination
    document = Capybara.string(response.body)
    links = document.all('.switch-service-control a').map { |link| link['href'] }
    expect(links.uniq.size).to eq(1)
    links.first
  end

  [true, false].each do |hybrid|
    context "with hybrid search #{hybrid ? 'enabled' : 'disabled'}" do
      before do
        hybrid ? enable_feature(:hybrid_search) : disable_feature(:hybrid_search)
        stub_searches(hybrid:)
      end

      { '' => '/xi', '/xi' => '' }.each do |source, destination|
        context "when switching from #{source.presence || 'GB'} to #{destination.presence || 'GB'}" do
          it 'keeps the submitted search term' do
            post "#{source}/search", params: { q: 'horses & ponies', request_id: 'original-search' }

            expect(response).to have_http_status(:ok)
            link = switch_destination
            expect(URI(link).path).to eq("#{destination}/search")
            query = Rack::Utils.parse_nested_query(URI(link).query)
            expect(query).to include('q' => 'horses & ponies')
            expect(query).not_to have_key('request_id')

            get link, headers: { 'HTTP_REFERER' => "http://www.example.com#{source}/search" }

            expect(response).to have_http_status(:ok)
            expect(response.body).to include('horses &amp; ponies')
          end

          it 'recovers from a queryless service switch' do
            get "#{destination}/search", headers: { 'HTTP_REFERER' => "http://www.example.com#{source}/search" }

            expect(response).to redirect_to("#{destination}/find_commodity")
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(response.body).to include('Look up commodity codes')
          end

          it 'keeps the selected suggestion and filters' do
            post "#{source}/search", params: {
              q: 'Horses',
              resource_id: '67890',
              resource_id_query: 'Horses',
              request_id: 'original-search',
              search: { country: 'FR', 'as_of(1i)' => '2026', 'as_of(2i)' => '2', 'as_of(3i)' => '1' },
            }

            expect(response).to have_http_status(:ok)
            link = switch_destination
            query = Rack::Utils.parse_nested_query(URI(link).query)
            expect(query).to include(
              'q' => 'Horses', 'resource_id' => '67890', 'country' => 'FR',
              'year' => '2026', 'month' => '2', 'day' => '1'
            )
            expect(query).not_to have_key('request_id')

            get link, headers: { 'HTTP_REFERER' => "http://www.example.com#{source}/search" }

            expect(response).to have_http_status(:ok)
            expect(switch_destination).to include('resource_id=67890', 'country=FR', 'year=2026')
          end
        end
      end
    end
  end

  describe 'searches without a term' do
    before do
      enable_feature(:hybrid_search)
      stub_searches(hybrid: true)
    end

    ['', '/xi'].each do |service|
      context "with #{service.presence || 'GB'} selected" do
        [
          '/search',
          '/uk/search',
          '/xi/search',
          '/search?q=%20',
          '/search?q=%5B%5D',
          '/search?search%5Bq%5D=%20',
          '/search?q=%5B%5D&search%5Bq%5D=horses',
        ].each do |referring_path|
          it "recovers from #{referring_path}" do
            get "#{service}/search", headers: { 'HTTP_REFERER' => "http://www.example.com#{referring_path}" }

            expect(response).to redirect_to("#{service}/find_commodity")
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(response.body).to include('Look up commodity codes')
          end
        end

        {
          'a top-level term' => { q: 'horses' },
          'a nested term' => { search: { q: 'horses' } },
          'a nested term and blank top-level term' => { q: '', search: { q: 'horses' } },
          'a top-level term and blank nested term' => { q: 'horses', search: { q: '' } },
        }.each do |description, query|
          it "keeps valid referring results with #{description}" do
            referring_query = Rack::Utils.build_nested_query(query)
            get "#{service}/search", headers: { 'HTTP_REFERER' => "http://www.example.com#{service}/search?#{referring_query}" }

            expect(response).to redirect_to("http://www.example.com#{service}/search?#{CGI.unescape(referring_query)}")
            follow_redirect!
            expect(response).to have_http_status(:ok)
          end
        end

        it 'keeps existing same-site returns' do
          get "#{service}/search",
              params: { search: { anchor: 'search' } },
              headers: { 'HTTP_REFERER' => "http://www.example.com#{service}/find_commodity?search_mode=guided&invalid_date=true" }

          expect(response.location).to eq("http://www.example.com#{service}/find_commodity?#search")
          follow_redirect!
          expect(response).to have_http_status(:ok)
        end

        it 'does not return to an external website' do
          get "#{service}/search", headers: { 'HTTP_REFERER' => 'https://other.example/search?q=horses' }

          expect(response).to redirect_to("#{service}/find_commodity")
        end
      end
    end
  end
end
