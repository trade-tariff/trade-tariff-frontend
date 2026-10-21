require 'spec_helper'

RSpec.describe SearchController, type: :request do
  describe 'unavailable internal suggestions' do
    {
      hybrid_search: :search_suggestions_path,
      interactive_search: :interactive_search_suggestions_path,
    }.each do |feature, route|
      context "with #{feature}" do
        before { enable_feature(feature) }

        [Faraday::TimeoutError, Faraday::ConnectionFailed, Faraday::ServerError].each do |error|
          it "returns empty suggestions for #{error}", :aggregate_failures do
            stub_api_request('search_suggestions', internal: true)
              .with(query: { q: 'Horses' }).to_raise(error)

            get public_send(route), params: { term: 'Horses' }

            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to eq('results' => [], 'use_resource_ids' => true)
          end
        end
      end
    end
  end

  # A browser keeps the original Referer across redirects. Redirecting an empty search
  # back to a search page sends the browser to /search again with the same Referer. That
  # loops until the browser gives up after about 20 redirects.
  describe 'an empty search from a search page' do
    before do
      %w[uk xi].each do |backend|
        stub_api_request('search', :post, backend:).to_return(
          status: 200,
          body: { data: [] }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
        )
      end
    end

    {
      '/search' => '/find_commodity',
      '/uk/search' => '/find_commodity',
      '/search?year=2025' => '/find_commodity',
      '/search?q=' => '/find_commodity',
      '/xi/search' => '/xi/find_commodity',
    }.each do |referer_path, expected_redirect|
      context "when the request is GET #{referer_path}" do
        let(:request_path) { referer_path.split('?').first }

        it "redirects to #{expected_redirect}", :aggregate_failures do
          get request_path, headers: { 'Referer' => "http://www.example.com#{referer_path}" }

          expect(response).to redirect_to(expected_redirect)
        end
      end
    end

    it 'redirects a POST to the find commodity page' do
      post '/search', headers: { 'Referer' => 'http://www.example.com/search' }

      expect(response).to redirect_to('/find_commodity')
    end

    it 'redirects a POST in the XI service to the XI find commodity page' do
      post '/xi/search', headers: { 'Referer' => 'http://www.example.com/xi/search' }

      expect(response).to redirect_to('/xi/find_commodity')
    end

    it 'still redirects back to a page that is not a search page' do
      get '/search', headers: { 'Referer' => 'http://www.example.com/chapters/01' }

      expect(response).to redirect_to('/chapters/01?')
    end
  end

  describe 'POST /search' do
    context 'when guided search advances to a new question' do
      before do
        enable_feature(:interactive_search)
        stub_api_request('search', :post, internal: true).to_return(
          status: 200,
          body: {
            data: [],
            meta: {
              interactive_search: {
                query: 'horse',
                request_id: 'guided-request-123',
                answers: [
                  { question: 'What is the horse used for?', options: %w[Sport Other], answer: 'Other' },
                  { question: 'What is it made from?', options: %w[Wood Other], answer: nil },
                ],
              },
            },
          }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
        )
      end

      it 'does not select the previous answer' do
        post perform_search_path,
             params: {
               q: 'horse',
               interactive_search: 'true',
               request_id: 'guided-request-123',
               current_question: 'What is the horse used for?',
               current_options: %w[Sport Other].to_json,
               interactive_search_form: { answer: 'Other' },
             }

        expect(Capybara.string(response.body)).to have_unchecked_field('Other')
      end
    end
  end
end
