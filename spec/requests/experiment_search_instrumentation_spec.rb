require 'spec_helper'

RSpec.describe 'Experiment search instrumentation', type: :request do
  let(:response_body) do
    {
      data: [],
      meta: { interactive_search: { query: 'horses', answers: [] } },
    }.to_json
  end

  around do |example|
    previous = ActionController::Parameters.action_on_unpermitted_parameters
    ActionController::Parameters.action_on_unpermitted_parameters = :raise
    example.run
  ensure
    ActionController::Parameters.action_on_unpermitted_parameters = previous
  end

  before { enable_feature(:interactive_search) }

  it 'sends the trusted enrolled label rather than the submitted value' do
    stub = stub_api_request('search', :post, internal: true)
      .with { |request| JSON.parse(request.body)['experiment'] == 'trstd-trdr' }
      .to_return(status: 200, body: response_body, headers: { 'content-type' => 'application/json' })

    travel_to(Time.utc(2026, 7, 27, 12)) do
      get '/trusted-trader-guided-search'
      post '/search', params: { q: 'horses', interactive_search: 'true', experiment: 'spoofed' }
    end

    expect(stub).to have_been_requested
  end

  it 'drops a submitted label without an active enrolment' do
    stub = stub_api_request('search', :post, internal: true)
      .with { |request| JSON.parse(request.body).exclude?('experiment') }
      .to_return(status: 200, body: response_body, headers: { 'content-type' => 'application/json' })

    post '/search', params: { q: 'horses', interactive_search: 'true', experiment: 'spoofed' }

    expect(stub).to have_been_requested
  end
end
