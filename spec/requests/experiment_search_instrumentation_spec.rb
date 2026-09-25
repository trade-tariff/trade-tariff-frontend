require 'spec_helper'

RSpec.describe 'Experiment search instrumentation', type: :request do
  let(:experiment) { Rails.application.config.experiment_urls.fetch(:trusted_trader_guided_search) }

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
      get experiment.path
      post '/search', params: { q: 'horses', interactive_search: 'true', experiment: 'spoofed' }
    end

    expect(stub).to have_been_requested
  end

  it 'records the HMRC users label on later searches' do
    stub = stub_api_request('search', :post, internal: true)
      .with { |request| JSON.parse(request.body)['experiment'] == 'hmrc-users' }
      .to_return(status: 200, body: response_body, headers: { 'content-type' => 'application/json' })

    travel_to(Time.utc(2026, 9, 14, 12)) { get '/hmrc-users' }
    travel_to(Time.utc(2026, 10, 14, 12)) do
      post '/search', params: { q: 'horses', interactive_search: 'true', experiment: 'spoofed' }
    end

    expect(stub).to have_been_requested
  end

  it 'records the HMRC traders label on later searches' do
    stub = stub_api_request('search', :post, internal: true)
      .with { |request| JSON.parse(request.body)['experiment'] == 'hmrc-traders' }
      .to_return(status: 200, body: response_body, headers: { 'content-type' => 'application/json' })

    travel_to(Time.utc(2026, 9, 25, 12)) { get '/hmrc-traders' }
    travel_to(Time.utc(2026, 10, 25, 12)) do
      post '/search', params: { q: 'horses', interactive_search: 'true', experiment: 'spoofed' }
    end

    expect(stub).to have_been_requested
  end

  it 'retains the demo label on later searches' do
    stub = stub_api_request('search', :post, internal: true)
      .with { |request| JSON.parse(request.body)['experiment'] == 'demo' }
      .to_return(status: 200, body: response_body, headers: { 'content-type' => 'application/json' })

    travel_to(Time.utc(2026, 9, 10, 12)) { get '/search-beta-demo' }
    travel_to(Time.utc(2026, 10, 10, 12)) do
      post '/search', params: { q: 'horses', interactive_search: 'true', experiment: 'spoofed' }
    end

    expect(stub).to have_been_requested
  end

  it 'stamps Flagsmith-selected searches as tenpct without an enrolment' do
    stub = stub_api_request('search', :post, internal: true)
      .with { |request| JSON.parse(request.body)['experiment'] == 'tenpct' }
      .to_return(status: 200, body: response_body, headers: { 'content-type' => 'application/json' })

    post '/search', params: { q: 'horses', interactive_search: 'true', experiment: 'demo' }

    expect(stub).to have_been_requested
  end

  it 'does not stamp tenpct when Flagsmith is unavailable' do
    allow(FlagsmithClient.instance).to receive(:get_flags_for).and_raise(Faraday::ConnectionFailed, 'offline')
    stub_search_without_tenpct

    post '/search', params: { q: 'horses', interactive_search: 'true' }

    expect_search_without_tenpct
  end

  it 'does not stamp tenpct when Flagsmith has not selected the search' do
    disable_feature(:interactive_search)
    stub = stub_api_request('search', :post)
      .with { |request| request.body.to_s.exclude?('experiment=') }
      .to_return(jsonapi_response(:search, attributes_for(:search_outcome, :fuzzy_match)))

    post '/search', params: { q: 'horses', experiment: 'demo' }

    expect(stub).to have_been_requested
  end

  def stub_search_without_tenpct
    stub_api_request('search', :post, internal: true)
      .to_return(status: 200, body: response_body, headers: { 'content-type' => 'application/json' })
    stub_api_request('search', :post)
      .to_return(jsonapi_response(:search, attributes_for(:search_outcome, :fuzzy_match)))
  end

  def expect_search_without_tenpct
    expect(WebMock).not_to(have_requested(:post, %r{/search$}).with { |request| request.body.to_s.include?('tenpct') })
  end
end
