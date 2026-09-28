require 'spec_helper'

RSpec.describe 'Guided search initial submission telemetry', :aggregate_failures, type: :request do
  let(:journey_events) { [] }

  around do |example|
    subscriber = ActiveSupport::Notifications.subscribe('guided_search.journey') do |*args|
      journey_events << ActiveSupport::Notifications::Event.new(*args).payload
    end
    example.run
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  before { enable_feature(:interactive_search) }

  it 'logs an invalid direct submit before validation and does not enqueue' do
    post perform_search_path, params: { q: '', interactive_search: 'true', request_id: 'request-123' }

    expect(response).to have_http_status(:ok)
    expect(journey_events.map { |event| event[:outcome] }).to eq(%w[initial_submitted input_error])
    expect(journey_events.first).to include(submission_source: 'server_direct', request_id: 'request-123')
    expect(journey_events.second[:request_id]).to eq('request-123')
    expect(WebMock).not_to have_requested(:post, %r{queued_searches})
  end

  it 'does not log another initial submit when the browser already recorded it' do
    post perform_search_path, params: {
      q: '', interactive_search: 'true', request_id: 'request-123', telemetry_submission_id: 'submission-1'
    }

    expect(journey_events.map { |event| event[:outcome] }).to eq(%w[input_error])
    expect(journey_events.sole).to include(request_id: 'request-123')
  end

  it 'does not start a journey for a question submit' do
    post perform_search_path, params: {
      q: 'horse',
      interactive_search: 'true',
      request_id: 'request-123',
      current_question: 'Material?',
      current_options: '["Wood"]',
      interactive_search_form: { answer: '' },
    }

    expect(journey_events.map { |event| event[:outcome] }).not_to include('initial_submitted')
    expect(journey_events).to include(hash_including(outcome: 'question', request_id: 'request-123'))
  end

  it 'keeps question identity stable and distinct at the same ordinal' do
    shared = { request_id: 'request-123', question_number: 2 }
    material = GuidedSearch::JourneyInstrumentation.question_id(**shared, question: 'What is the material?', options: %w[Wood Metal])
    use = GuidedSearch::JourneyInstrumentation.question_id(**shared, question: 'What is it used for?', options: %w[Sport Other])

    expect(material).to eq(GuidedSearch::JourneyInstrumentation.question_id(**shared, question: 'What is the material?', options: %w[Wood Metal]))
    expect(material).not_to eq(use)
    expect(material).to match(/\A[0-9a-f]{64}\z/)
  end

  it 'counts a rendered option only after the server accepts it' do
    stub_api_request('search', :post, internal: true).to_return(
      status: 200,
      body: { data: [], meta: { interactive_search: { query: 'horse', request_id: 'request-123', answers: [] } } }.to_json,
      headers: { 'content-type' => 'application/json' },
    )
    base = {
      q: 'horse',
      interactive_search: 'true',
      request_id: 'request-123',
      current_question: 'Material?',
      current_options: %w[Wood Metal].to_json,
    }
    post perform_search_path, params: base.merge(interactive_search_form: { answer: '' })

    expect(journey_events.map { |event| event[:outcome] }).not_to include('answer_accepted')
    shown_question_id = Capybara.string(response.body).find('input[name="telemetry_question_id"]', visible: :all)[:value]

    journey_events.clear
    post perform_search_path, params: base.merge(interactive_search_form: { answer: 'Wood' }, telemetry_submission_id: 'submission-1')

    accepted = journey_events.find { |event| event[:outcome] == 'answer_accepted' }
    expect(accepted).to include(response_source: 'server_accepted', question_response: 'normal', request_id: 'request-123', submission_id: 'submission-1')
    expect(accepted[:question_id]).to eq(shown_question_id)
    expect(journey_events.to_json).not_to include('Wood')
    expect(journey_events.to_json).not_to include('Material')
  end

  it 'retains the early request id when displaying blocking guidance' do
    stub_api_request('search', :post, internal: true).to_return(
      status: 200,
      body: {
        data: [],
        meta: {
          interactive_search: { query: 'exampleterm', request_id: 'browser-request-id', answers: [] },
          description_intercept: { excluded: true, message_header: 'Stop', message: 'Guidance' },
        },
      }.to_json,
      headers: { 'content-type' => 'application/json' },
    )
    post perform_search_path, params: {
      q: 'exampleterm', interactive_search: 'true', request_id: 'browser-request-id', telemetry_submission_id: 'submission-1'
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('browser-request-id')
    expect(journey_events).to include(hash_including(outcome: 'blocking_guidance', request_id: 'browser-request-id'))
  end
end
