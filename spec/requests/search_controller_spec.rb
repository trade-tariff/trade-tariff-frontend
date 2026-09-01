require 'spec_helper'

RSpec.describe SearchController, type: :request do
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
