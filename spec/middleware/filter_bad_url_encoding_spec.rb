require 'spec_helper'

RSpec.describe FilterBadUrlEncoding do
  subject(:middleware) { described_class.new(app) }

  let(:app) { ->(_env) { [200, { 'Content-Type' => 'text/plain' }, %w[OK]] } }

  it 'delegates requests with valid ASCII paths and query strings', :aggregate_failures do
    status, headers, response = middleware.call(Rack::MockRequest.env_for('/search?q=tea'))

    expect(status).to eq(200)
    expect(headers).to eq('Content-Type' => 'text/plain')
    expect(response).to eq(%w[OK])
  end

  it 'returns a bad request for invalid nested query parameters', :aggregate_failures do
    status, headers, response = middleware.call(Rack::MockRequest.env_for('/search?query[letter]=%'))

    expect(status).to eq(400)
    expect(headers).to eq('Content-Type' => 'application/json')
    expect(JSON.parse(response.first)).to eq(
      'errors' => [
        {
          'status' => '400',
          'title' => 'There was a problem with your query',
          'source' => { 'parameter' => 'Invalid query string' },
        },
      ],
    )
  end

  it 'returns a bad request for non-ASCII paths' do
    env = Rack::MockRequest.env_for('/search')
    env['PATH_INFO'] = "/search/\u00E9"

    status, = middleware.call(env)

    expect(status).to eq(400)
  end

  it 'returns a bad request for non-ASCII query strings' do
    env = Rack::MockRequest.env_for('/search')
    env['QUERY_STRING'] = "q=\u00E9"

    status, = middleware.call(env)

    expect(status).to eq(400)
  end
end
