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
    post perform_search_path, params: { q: '', interactive_search: 'true' }

    expect(response).to have_http_status(:ok)
    expect(journey_events.map { |event| event[:outcome] }).to eq(%w[initial_submitted input_error])
    expect(journey_events.first).to include(submission_source: 'server_direct')
    expect(journey_events.first[:journey_id]).to eq(journey_events.second[:journey_id])
    expect(WebMock).not_to have_requested(:post, %r{queued_searches})
  end

  it 'does not log another initial submit when the browser already owns the journey' do
    post perform_search_path, params: { q: '', interactive_search: 'true', telemetry_journey_id: 'journey-abc' }

    expect(journey_events.map { |event| event[:outcome] }).to eq(%w[input_error])
    expect(journey_events.sole).to include(journey_id: 'journey-abc')
  end

  it 'does not start a journey for a question submit' do
    post perform_search_path, params: {
      q: 'horse',
      interactive_search: 'true',
      request_id: 'request-123',
      current_question: 'Material?',
      current_options: '["Wood"]',
      interactive_search_form: { answer: '' },
      telemetry_journey_id: 'journey-abc',
    }

    expect(journey_events.map { |event| event[:outcome] }).not_to include('initial_submitted')
    expect(journey_events).to include(hash_including(outcome: 'question', journey_id: 'journey-abc'))
    expect(journey_events.to_json).not_to include('Material')
  end

  it 'keeps question identity stable and distinct at the same ordinal' do
    shared = { journey_id: 'journey-abc', request_id: 'request-123', question_number: 2 }
    material = GuidedSearch::JourneyInstrumentation.question_id(**shared, question: 'What is the material?', options: %w[Wood Metal])
    use = GuidedSearch::JourneyInstrumentation.question_id(**shared, question: 'What is it used for?', options: %w[Sport Other])

    expect(material).to eq(GuidedSearch::JourneyInstrumentation.question_id(**shared, question: 'What is the material?', options: %w[Wood Metal]))
    expect(material).not_to eq(use)
    expect(material).to match(/\A[0-9a-f]{64}\z/)
    expect(material).not_to include('material')
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
      telemetry_journey_id: 'journey-abc',
      current_question: 'Material?',
      current_options: %w[Wood Metal].to_json,
    }
    post perform_search_path, params: base.merge(interactive_search_form: { answer: 'Nope' })

    expect(journey_events.map { |event| event[:outcome] }).not_to include('answer_accepted')

    journey_events.clear
    post perform_search_path, params: base.merge(interactive_search_form: { answer: 'Wood' })

    accepted = journey_events.find { |event| event[:outcome] == 'answer_accepted' }
    expect(accepted).to include(response_source: 'server_accepted', question_response: 'normal', journey_id: 'journey-abc')
    expect(accepted[:question_id]).to match(/\A[0-9a-f]{64}\z/)
    expect(journey_events.to_json).not_to include('Wood')
    expect(journey_events.to_json).not_to include('Material')
  end

  it 'drops a malformed telemetry id without copying it into the log' do
    post perform_search_path, params: { q: '', interactive_search: 'true', telemetry_journey_id: 'bad id' }

    expect(journey_events.map { |event| event[:outcome] }).to eq(%w[input_error])
    expect(journey_events.sole).not_to have_key(:journey_id)
    expect(journey_events.to_json).not_to include('bad id')
  end
end
