# Opt-in synthetic frontend benchmark, not a production or Sidekiq load test.
# ORIGINAL one-second polling baseline, not the current staggered Stimulus cadence.
# Run from the repository root: bundle exec rspec script/benchmarks/queued_guided_search_spec.rb
require 'spec_helper'
require 'puma'
require 'net/http'

RSpec.describe 'Controlled queued search frontend benchmark', :aggregate_failures, type: :request do
  let(:server) do
    Puma::Server.new(Rails.application, nil, min_threads: 1, max_threads: 1).tap do |puma|
      puma.add_tcp_listener('127.0.0.1', 0)
    end
  end
  let(:port) { server.connected_ports.first }

  def now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def request_http(method, path, params = nil, cookie = nil)
    uri = URI("http://127.0.0.1:#{port}#{path}")
    request = method == :post ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
    request['Accept'] = path == '/search' ? 'text/html' : 'application/json'
    request['Cookie'] = cookie if cookie
    request.set_form_data(params) if params
    Net::HTTP.start(uri.host, uri.port, open_timeout: 2, read_timeout: 10) { |http| http.request(request) }
  end

  def search_result(request_id)
    { data: [],
      meta: { interactive_search: { request_id:,
                                    query: 'horse',
                                    answers: [
                                      { question: 'What type of horse?', options: %w[Racing Breeding], answer: nil },
                                    ] } } }
  end

  def measure_trial(mode, started)
    inputs = { q: 'horse', interactive_search: 'true', request_id: SecureRandom.uuid }
    path = mode == 'synchronous' ? '/search' : '/search/queued'
    start = now
    submission = Thread.new do
      response = request_http(:post, path, inputs)
      [response, now]
    end
    raise 'Search did not reach the backend stub' unless started.pop(timeout: 10)

    health_request = Thread.new do
      health_start = now
      health = request_http(:get, '/healthcheckz')
      [health, (now - health_start) * 1000]
    end
    accepted, submitted_at = submission.value
    initial_ms = (submitted_at - start) * 1000
    completed_at = submitted_at
    if mode == 'queued'
      payload = JSON.parse(accepted.body)
      cookie = accepted.get_fields('set-cookie').map { |value| value.split(';').first }.join('; ')
      poll_deadline = now + 10
      loop do
        raise 'Queued result did not complete' if now > poll_deadline

        status = request_http(:get, payload.fetch('poll_url'), nil, cookie)
        break if JSON.parse(status.body).fetch('status') == 'completed'

        sleep 1
      end
      response = request_http(:post, '/search', inputs.merge(payload.fetch('date')).merge(queued_search_id: payload.fetch('id'), queued_search_token: payload.fetch('token')), cookie)
      completed_at = now
      expect(response.code).to eq('200')
    else
      expect(accepted.code).to eq('200')
    end
    health, health_ms = health_request.value
    expect(health.code).to eq('200')
    { mode:, submission_ms: initial_ms.round(1), unrelated_ms: health_ms.round(1), total_ms: ((completed_at - start) * 1000).round(1) }
  ensure
    submission&.kill
    health_request&.kill
    submission&.join
    health_request&.join
  end
  private :measure_trial

  %w[synchronous queued].each do |mode|
    it "keeps #{mode} response clocks and polling independent of a slower healthcheck" do
      started = Queue.new
      health_started = Queue.new
      release_health = Queue.new
      received = Queue.new
      clock = 0
      allow(self).to receive(:now) do
        timestamp = clock
        received << :response if timestamp == (mode == 'synchronous' ? 2 : 3)
        timestamp
      end
      ok = instance_double(Net::HTTPOK, code: '200', body: { status: 'completed' }.to_json)
      accepted = instance_double(Net::HTTPAccepted, body: { id: 'job', token: 'token', date: {}, poll_url: '/poll' }.to_json, get_fields: ['session=cookie; path=/'])
      allow(self).to receive(:request_http) do |method, path, *_args|
        if path == '/healthcheckz'
          health_started << true
          release_health.pop
          clock = 50
          ok
        elsif path == '/poll'
          received << :poll
          ok
        elsif method == :post && (path == '/search/queued' || mode == 'synchronous')
          started << true
          health_started.pop
          clock = 2
          mode == 'synchronous' ? ok : accepted
        else
          clock = 3
          ok
        end
      end

      trial = Thread.new { measure_trial(mode, started) }
      # Timeouts bound deadlocks only; all measured time comes from the stubbed clock.
      expect(received.pop(timeout: 10)).to eq(:poll) if mode == 'queued'
      expect(received.pop(timeout: 10)).to eq(:response)
      release_health << true
      expect(trial.value).to include(submission_ms: 2000, total_ms: mode == 'synchronous' ? 2000 : 3000, unrelated_ms: 50_000)
    ensure
      release_health&.push(true)
      trial&.kill
      trial&.join
    end
  end

  it 'measures synchronous and queued waits with one Puma thread' do
    enable_feature(:interactive_search)
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::NullStore.new)
    started = Queue.new
    jobs = {}
    headers = { 'Content-Type' => 'application/json' }
    stub_api_request('search', :post, internal: true).to_return do |request|
      started << true
      sleep 2
      { status: 200, body: search_result(JSON.parse(request.body)['request_id']).to_json, headers: }
    end
    stub_api_request('queued_searches', :post, internal: true).to_return do |request|
      id = SecureRandom.uuid
      jobs[id] = { ready_at: now + 2, result: search_result(JSON.parse(request.body)['request_id']) }
      started << true
      { status: 202, body: { id:, status: 'queued' }.to_json, headers: }
    end
    stub_request(:get, %r{/internal/uk/queued_searches/}).to_return do |request|
      id = request.uri.path.split('/').last
      job = jobs.fetch(id)
      payload = if now >= job.fetch(:ready_at)
                  { id:, status: 'completed', response_status: 200, result: job.fetch(:result) }
                else
                  { id:, status: 'running' }
                end
      { status: 200, body: payload.to_json, headers: }
    end

    server.run
    request_http(:get, '/healthcheckz')
    samples = []
    %w[synchronous queued].each do |mode|
      3.times do
        samples << measure_trial(mode, started)
      end
    end
    File.write('/tmp/queued-guided-search-benchmark.json', JSON.pretty_generate(samples))
    puts JSON.pretty_generate(samples)
  ensure
    server&.stop(true)
  end
end
