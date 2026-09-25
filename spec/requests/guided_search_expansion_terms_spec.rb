require 'spec_helper'

RSpec.describe 'Guided search expansion terms', :aggregate_failures, type: :request do
  let(:headers) { { 'content-type' => 'application/json; charset=utf-8' } }
  let(:bodies) { [] }

  before do
    enable_feature(:interactive_search)
  end

  def question_response(expansion, question: 'What type of horse?')
    {
      status: 200,
      headers:,
      body: {
        data: [],
        meta: {
          interactive_search: {
            query: 'horse',
            request_id: 'journey-123',
            expanded_query: 'live horse',
            query_expansion: expansion,
            answers: [
              { question:, options: %w[Racing Breeding], answer: nil },
            ],
          },
        },
      }.to_json,
    }
  end

  def stub_search(*responses)
    stub_api_request('search', :post, internal: true).with { |request|
      bodies << JSON.parse(request.body)
      true
    }.to_return(*responses)
  end

  def expansion_field(body = response.body)
    Capybara.string(body).find('input[name="query_expansion"]', visible: :hidden)
  end

  it 'carries escaped expansion JSON through later questions' do
    stub_search(
      question_response({ 'ai_terms' => ['horse "mare" & <foal>'] }),
      question_response({ 'ai_terms' => %w[equine] }),
    )

    post perform_search_path, params: { q: 'horse', interactive_search: 'true' }

    expect(JSON.parse(expansion_field.value)).to eq('ai_terms' => ['horse "mare" & <foal>'])
    expect(response.body).to include('&quot;').and include('&lt;')
    expect(Capybara.string(response.body)).not_to have_text('horse "mare"')

    post perform_search_path, params: {
      q: 'horse',
      interactive_search: 'true',
      request_id: 'journey-123',
      expanded_query: 'live horse',
      query_expansion: expansion_field.value,
      current_question: 'What type of horse?',
      current_options: %w[Racing Breeding].to_json,
      interactive_search_form: { answer: 'Racing' },
    }

    expect(bodies.last).to include(
      'expanded_query' => 'live horse',
      'query_expansion' => { 'ai_terms' => ['horse "mare" & <foal>'] },
    )
    expect(JSON.parse(expansion_field.value)).to eq('ai_terms' => %w[equine])

    post perform_search_path, params: {
      q: 'horse',
      interactive_search: 'true',
      request_id: 'journey-123',
      expanded_query: 'live horse',
      query_expansion: expansion_field.value,
      current_question: 'What type of horse?',
      current_options: %w[Racing Breeding].to_json,
      interactive_search_form: { answer: 'Breeding' },
    }

    expect(bodies.last['query_expansion']).to eq('ai_terms' => %w[equine])
  end

  it 'keeps a known-empty term list explicit' do
    stub_search(question_response({ 'ai_terms' => [] }))

    post perform_search_path, params: {
      q: 'horse',
      interactive_search: 'true',
      query_expansion: '{"ai_terms":[]}',
    }

    expect(bodies.last['query_expansion']).to eq('ai_terms' => [])
    expect(expansion_field.value).to eq('{"ai_terms":[]}')
  end

  it 'omits absent expansion data' do
    stub_search(question_response(nil))

    post perform_search_path, params: { q: 'horse', interactive_search: 'true' }

    expect(bodies.last).not_to have_key('query_expansion')
    expect(response.body).not_to include('name="query_expansion"')
  end

  it 'drops invalid nested expansion data without failing the question' do
    stub_search(question_response({ 'ai_terms' => %w[mare] }))

    post perform_search_path, params: {
      q: 'horse',
      interactive_search: 'true',
      query_expansion: { ai_terms: [{}] },
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('What type of horse?')
    expect(bodies.last).not_to have_key('query_expansion')
  end

  it 'drops invalid expansion data without failing the question' do
    stub_search(question_response({ 'ai_terms' => ['', 1] }))

    post perform_search_path, params: { q: 'horse', interactive_search: 'true', query_expansion: '{"ai_terms":[1]}' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('What type of horse?')
    expect(bodies.last).not_to have_key('query_expansion')
    expect(response.body).not_to include('name="query_expansion"')
  end

  it 'preserves expansion JSON when answer validation fails' do
    post perform_search_path, params: {
      q: 'horse',
      interactive_search: 'true',
      request_id: 'journey-123',
      expanded_query: 'live horse',
      query_expansion: '{"ai_terms":["horse \\"mare\\""]}',
      current_question: 'What type of horse?',
      current_options: %w[Racing Breeding].to_json,
      interactive_search_form: { answer: '' },
    }

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(expansion_field.value)).to eq('ai_terms' => ['horse "mare"'])
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/search$})
  end

  it 'carries expansion terms through a blocking redirect' do
    blocking = {
      status: 200,
      headers:,
      body: {
        data: [],
        meta: {
          interactive_search: {
            query: 'horse',
            request_id: 'journey-123',
            expanded_query: 'live horse',
            query_expansion: { ai_terms: %w[mare] },
          },
          description_intercept: {
            excluded: true,
            message_header: 'Example guidance header',
            message: 'Example guidance message body',
          },
        },
      }.to_json,
    }
    stub_search(blocking, blocking)

    post perform_search_path, params: {
      q: 'horse',
      interactive_search: 'true',
      query_expansion: '{"ai_terms":["old"]}',
    }

    location = URI.parse(response.location)
    expect(response).to redirect_to(%r{/search})
    expect(Rack::Utils.parse_query(location.query)).to include(
      'expanded_query' => 'live horse',
      'query_expansion' => '{"ai_terms":["mare"]}',
    )

    follow_redirect!

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Example guidance header')
    expect(bodies.last['query_expansion']).to eq('ai_terms' => %w[mare])
    expect(bodies.last['expanded_query']).to eq('live horse')
  end

  it 'omits invalid expansion data from a blocking redirect' do
    stub_search(
      {
        status: 200,
        headers:,
        body: {
          data: [],
          meta: {
            interactive_search: {
              query: 'horse',
              request_id: 'journey-123',
              query_expansion: { ai_terms: [1] },
            },
            description_intercept: {
              excluded: true,
              message_header: 'Example guidance header',
              message: 'Example guidance message body',
            },
          },
        }.to_json,
      },
      {
        status: 200,
        headers:,
        body: {
          data: [],
          meta: {
            description_intercept: {
              excluded: true,
              message_header: 'Example guidance header',
              message: 'Example guidance message body',
            },
          },
        }.to_json,
      },
    )

    post perform_search_path, params: { q: 'horse', interactive_search: 'true' }
    expect(Rack::Utils.parse_query(URI.parse(response.location).query)).not_to have_key('query_expansion')

    follow_redirect!

    expect(response).to have_http_status(:ok)
    expect(bodies.last).not_to have_key('query_expansion')
  end

  it 'sends nested expansion terms on a queued follow-up' do
    id = 'aabbccdd-1234-4567-8901-aabbccddeeff'
    stub_api_request('queued_searches', :post, internal: true).to_return(
      status: 202, body: { id:, status: 'queued' }.to_json, headers:,
    )
    post '/search/queued', params: {
      q: 'horse',
      interactive_search: 'true',
      request_id: 'journey-123',
      query_expansion: { ai_terms: ['live horse'] },
      current_question: 'What type of horse?',
      current_options: %w[Racing Breeding].to_json,
      interactive_search_form: { answer: 'Racing' },
    }

    expect(response).to have_http_status(:accepted)
    expect(WebMock).to(have_requested(:post, %r{/internal/uk/queued_searches$}).with do |request|
      body = JSON.parse(request.body)
      body['query_expansion'] == { 'ai_terms' => ['live horse'] } &&
        body['answers'] == [{ 'question' => 'What type of horse?', 'options' => '["Racing","Breeding"]', 'answer' => 'Racing' }]
    end)
  end
end
