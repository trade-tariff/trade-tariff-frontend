require 'spec_helper'

RSpec.describe 'Queued guided search', :aggregate_failures, type: :request do
  let(:id) { 'aabbccdd-1234-4567-8901-aabbccddeeff' }
  let(:inputs) { { q: 'horse', interactive_search: 'true', request_id: 'journey-123' } }
  let(:headers) { { 'content-type' => 'application/json' } }
  let(:result) do
    { data: [],
      meta: { interactive_search: {
        query: 'horse',
        request_id: 'journey-123',
        answers: [
          { question: 'What is it used for?', options: %w[Sport Other], answer: nil },
        ],
      } } }
  end

  before do
    enable_feature(:interactive_search)
    stub_api_request('queued_searches', :post, internal: true).to_return(
      status: 202, body: { id:, status: 'queued' }.to_json, headers:,
    )
  end

  def enqueue(params = inputs)
    post('/search/queued', params:)
    expect(response).to have_http_status(:accepted)
    response.parsed_body
  end

  def poll(accepted)
    get accepted.fetch('poll_url')
  end

  def finish(accepted, overrides = {})
    post '/search', params: inputs.merge(
      queued_search_id: accepted.fetch('id'), queued_search_token: accepted.fetch('token'),
    ).merge(overrides)
  end

  def stub_completed(job_id = id, payload = result)
    stub_api_request("queued_searches/#{job_id}", internal: true).to_return(
      status: 200, body: { id: job_id, status: 'completed', response_status: 200, result: payload }.to_json, headers:,
    )
  end

  def stub_running(job_id = id)
    stub_api_request("queued_searches/#{job_id}", internal: true).to_return(
      status: 200, body: { id: job_id, status: 'running' }.to_json, headers:,
    )
  end

  it 'queues the validated query and merged answer with a signed handoff' do
    inputs.merge!(current_question: 'Material?', current_options: '["Wood"]', interactive_search_form: { answer: 'Wood' })
    accepted = enqueue

    expect(accepted).to include('id' => id, 'request_id' => 'journey-123')
    expect(accepted.fetch('token')).to be_present
    expect(URI.parse(accepted.fetch('poll_url')).path).to eq("/search/queued/#{id}")
    expect(WebMock).to(have_requested(:post, %r{/internal/uk/queued_searches$}).with do |request|
      JSON.parse(request.body).slice('q', 'answers') == {
        'q' => 'horse', 'answers' => [{ 'question' => 'Material?', 'options' => '["Wood"]', 'answer' => 'Wood' }]
      }
    end)
  end

  it 'polls without Flagsmith evaluation or synchronous search' do
    accepted = enqueue
    stub_running
    allow(FlagsmithClient.instance).to receive(:get_flags_for).and_call_original

    poll(accepted)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq('status' => 'running')
    expect(response.headers['Cache-Control']).to include('no-store')
    expect(FlagsmithClient.instance).not_to have_received(:get_flags_for)
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/search$})
  end

  it 'renders a completed question without another search' do
    accepted = enqueue
    stub_completed

    finish(accepted)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('What is it used for?')
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/search$})
  end

  it 'lets an accepted step finish after disabling guided search, but rejects new submissions' do
    accepted = enqueue
    stub_completed
    disable_feature(:interactive_search)

    poll(accepted)
    expect(response.parsed_body).to eq('status' => 'completed')
    finish(accepted)
    expect(response.body).to include('What is it used for?')
    post '/search/queued', params: inputs
    expect(response).to have_http_status(:not_found)
    expect(WebMock).to have_requested(:post, %r{/internal/uk/queued_searches$}).once
  end

  it 'rejects polling and final handoff from a different session' do
    accepted = enqueue
    other_browser = ActionDispatch::Integration::Session.new(Rails.application)
    other_browser.get accepted.fetch('poll_url')
    expect(other_browser.response).to have_http_status(:not_found)
    other_browser.post '/search', params: inputs.merge(queued_search_id: id, queued_search_token: accepted.fetch('token'))
    expect(other_browser.response).to have_http_status(:not_found)
    expect(WebMock).not_to have_requested(:get, %r{/internal/uk/queued_searches/#{id}$})
  end

  it 'rejects missing, tampered and expired tokens without backend lookups' do
    accepted = enqueue
    get "/search/queued/#{id}"
    expect(response).to have_http_status(:not_found)
    get "/search/queued/#{id}", params: { token: "#{accepted.fetch('token')}x" }
    expect(response).to have_http_status(:not_found)
    travel 61.minutes do
      poll(accepted)
      expect(response).to have_http_status(:not_found)
    end
    expect(WebMock).not_to have_requested(:get, %r{/internal/uk/queued_searches/})
  end

  it 'binds the token to the job and service' do
    accepted = enqueue
    get '/search/queued/aabbccdd-1234-4567-8901-aabbccddee00', params: { token: accepted.fetch('token') }
    expect(response).to have_http_status(:not_found)
    get "/xi/search/queued/#{id}", params: { token: accepted.fetch('token') }
    expect(response).to have_http_status(:not_found)
    expect(WebMock).not_to have_requested(:get, %r{/internal/(uk|xi)/queued_searches/})
  end

  [
    { q: 'different goods' },
    { request_id: 'different-journey' },
    { year: '2001', month: '1', day: '1' },
    { answers: [{ question: 'Material?', options: '["Wood"]', answer: 'Wood' }] },
    { expanded_query: 'different expansion' },
  ].each do |override|
    it "rejects a completed id with changed #{override.keys.first}" do
      accepted = enqueue
      finish(accepted, override)

      expect(response).to have_http_status(:not_found)
      expect(WebMock).not_to have_requested(:get, %r{/internal/uk/queued_searches/#{id}$})
    end
  end

  it 'cannot substitute another job through an unrelated id parameter on final handoff' do
    accepted = enqueue
    other_id = 'aabbccdd-1234-4567-8901-aabbccddee99'
    stub_completed(other_id)

    finish(accepted, id:, queued_search_id: other_id)

    expect(response).to have_http_status(:not_found)
    expect(WebMock).not_to have_requested(:get, %r{/internal/uk/queued_searches/#{other_id}$})
  end

  it 'rejects a changed experiment during final handoff' do
    accepted = enqueue
    allow(Current).to receive(:experiment).and_return('different-experiment')

    finish(accepted)

    expect(response).to have_http_status(:not_found)
    expect(WebMock).not_to have_requested(:get, %r{/internal/uk/queued_searches/#{id}$})
  end

  it 'retains ownership when two tabs submit from the same starting cookie' do
    enqueue
    initial_cookies = cookies.to_hash
    ids = %w[aabbccdd-1234-4567-8901-aabbccddee01 aabbccdd-1234-4567-8901-aabbccddee02]
    stub_api_request('queued_searches', :post, internal: true).to_return(*ids.map do |job_id|
      { status: 202, body: { id: job_id, status: 'queued' }.to_json, headers: }
    end)
    tabs = ids.map do
      ActionDispatch::Integration::Session.new(Rails.application).tap do |tab|
        initial_cookies.each { |name, value| tab.cookies[name] = value }
      end
    end
    # Both requests use the original cookie, as overlapping browser requests do.
    acceptances = tabs.map do |tab|
      tab.post '/search/queued', params: inputs
      expect(tab.response).to have_http_status(:accepted)
      tab.response.parsed_body
    end
    acceptances.each do |accepted|
      stub_running(accepted.fetch('id'))
      tabs.last.get accepted.fetch('poll_url')
      expect(tabs.last.response).to have_http_status(:ok)
    end
  end

  it 'keeps the session small and unchanged regardless of the number or size of searches' do
    enqueue
    initial_session = request.session.to_h.deep_dup
    12.times do |index|
      enqueue(inputs.merge(q: 'x' * 1000, request_id: "journey-#{index}"))
      expect(request.session.to_h).to eq(initial_session)
    end

    expect(initial_session).not_to have_key('queued_guided_searches')
    session_cookie = cookies[Rails.application.config.session_options.fetch(:key)]
    expect(session_cookie.bytesize).to be < ActionDispatch::Cookies::MAX_COOKIE_SIZE
  end

  it 'returns validation errors before enqueueing' do
    post '/search/queued', params: inputs.merge(q: 'a')

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to include('validation_failed' => true)
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/queued_searches$})
  end

  it 'does not enqueue unanswered questions' do
    post '/search/queued', params: inputs.merge(current_question: 'Material?', current_options: '["Wood"]')

    expect(response).to have_http_status(:unprocessable_content)
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/queued_searches$})
  end

  it 'reports failed and expired jobs without restarting' do
    accepted = enqueue
    stub_api_request("queued_searches/#{id}", internal: true).to_return(
      { status: 200, body: { id:, status: 'failed', response_status: 500 }.to_json, headers: },
      { status: 404, body: '', headers: },
    )

    poll(accepted)
    expect(response.parsed_body).to eq('status' => 'failed')
    poll(accepted)
    expect(response).to have_http_status(:not_found)
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/search$})
  end

  it 'does not silently restart if the result expires before rendering' do
    accepted = enqueue
    stub_api_request("queued_searches/#{id}", internal: true).to_return(status: 404, body: '', headers:)

    finish(accepted)

    expect(response.body).to include('Please try your search again')
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/search$})
  end

  it 'retains the submission date across midnight' do
    accepted = nil
    travel_to(Time.zone.local(2025, 7, 1, 23, 59)) { accepted = enqueue }
    stub_completed

    travel_to(Time.zone.local(2025, 7, 2, 0, 1)) do
      finish(accepted, accepted.fetch('date'))
      expect(response.body).to include('What is it used for?')
    end
  end

  context 'with result caching' do
    let(:cache) { ActiveSupport::Cache::MemoryStore.new }

    before { allow(Rails).to receive(:cache).and_return(cache) }

    it 'accepts a real backend id even with a warm synchronous result, and survives cache loss' do
      search = Search.new(q: 'horse', request_id: 'journey-123')
      cache.write(search.interactive_search_cache_key, Search.internal_result(result.deep_stringify_keys))
      accepted = enqueue
      expect(accepted.fetch('id')).to eq(id)
      stub_completed

      poll(accepted)
      expect(response.parsed_body).to eq('status' => 'completed')
      cache.clear
      poll(accepted)
      expect(response.parsed_body).to eq('status' => 'completed')
      cache.clear
      finish(accepted)
      expect(response.body).to include('What is it used for?')
      expect(WebMock).to have_requested(:get, %r{/internal/uk/queued_searches/#{id}$}).times(3)
      expect(WebMock).not_to have_requested(:post, %r{/internal/uk/search$})
    end

    it 'caches the completed job for polling and handoff without another backend read' do
      accepted = enqueue
      stub_completed
      poll(accepted)
      poll(accepted)
      finish(accepted)

      expect(response.body).to include('What is it used for?')
      expect(WebMock).to have_requested(:get, %r{/internal/uk/queued_searches/#{id}$}).once
    end

    [Zlib::DataError, TypeError].each do |error_class|
      it "treats #{error_class} from cache decoding as a miss, not a failed search" do
        allow(cache).to receive(:read).and_raise(error_class)
        accepted = enqueue
        stub_completed
        poll(accepted)
        expect(response.parsed_body).to eq('status' => 'completed')
        finish(accepted)
        expect(response.body).to include('What is it used for?')
        expect(WebMock).not_to have_requested(:post, %r{/internal/uk/search$})
      end
    end

    it 'does not fail a valid result when cache serialization fails' do
      accepted = enqueue
      stub_completed
      allow(cache).to receive(:write).and_call_original
      allow(cache).to receive(:write).with(start_with('queued_search/'), anything, anything).and_raise(TypeError)

      poll(accepted)
      expect(response.parsed_body).to eq('status' => 'completed')
      finish(accepted)
      expect(response.body).to include('What is it used for?')
    end

    [
      {},
      { data: [nil] },
      { data: [], errors: [{ title: 'Search failed' }] },
      { data: [], meta: 'invalid' },
      { data: [], meta: { interactive_search: { answers: 'invalid' } } },
      { data: [], meta: { interactive_search: { answers: [{ question: 'Which?', options: 'invalid' }] } } },
      { data: [], meta: { interactive_search: { result_limit: -1 } } },
      { data: [], meta: { interactive_search: { answers: [{ question: 'Which?', options: [], answer: nil }] } } },
      { data: [], meta: { interactive_search: { answers: [{ question: 'Which?', options: [' '], answer: nil }] } } },
      { data: [], meta: { search_failures: %w[query_expansion_failed], interactive_search: { request_id: 'x' * 6000 } } },
      { data: [], meta: { description_intercept: 'invalid' } },
    ].each_with_index do |malformed, index|
      it "recovers from malformed completed payload #{index + 1} without caching false success" do
        accepted = enqueue
        stub_completed(id, malformed)
        allow(cache).to receive(:write).and_call_original

        poll(accepted)
        expect(response).to have_http_status(:service_unavailable)
        finish(accepted)
        expect(response.body).to include('Please try your search again')
        expect(cache).not_to have_received(:write).with(start_with('queued_search/'), anything, anything)
        expect(WebMock).not_to have_requested(:post, %r{/internal/uk/search$})
      end
    end
  end

  it 'returns unavailable without an accepted id when submission fails' do
    stub_api_request('queued_searches', :post, internal: true).to_return(status: 503, body: '', headers:)
    post '/search/queued', params: inputs

    expect(response).to have_http_status(:service_unavailable)
    expect(response.parsed_body).not_to have_key('id')
  end

  it 'does not expose new submissions when guided search is unavailable' do
    disable_feature(:interactive_search)
    post '/search/queued', params: inputs

    expect(response).to have_http_status(:not_found)
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/queued_searches$})
  end

  it 'rejects an invalid date before enqueueing' do
    post '/search/queued', params: inputs.merge(year: '2025', month: '2', day: '31')

    expect(response).to have_http_status(:unprocessable_content)
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/queued_searches$})
  end

  it 'rejects submission without CSRF protection' do
    previous = SearchController.allow_forgery_protection
    SearchController.allow_forgery_protection = true
    post '/search/queued', params: inputs

    expect(response).to have_http_status(:unprocessable_content)
    expect(WebMock).not_to have_requested(:post, %r{/internal/uk/queued_searches$})
  ensure
    SearchController.allow_forgery_protection = previous
  end
end
