class MockRackApp
  attr_reader :request_body

  def initialize
    @request_headers = {}
  end

  def call(env)
    @env = env
    [200, { 'Content-Type' => 'text/plain' }, %w[OK]]
  end

  def [](key)
    @env[key]
  end
end

RSpec.describe TradeTariffFrontend::BasicAuth do
  subject(:middleware) do
    described_class.new(app) do |username, password|
      username == 'test' && password == 'test'
    end
  end

  let(:app) { MockRackApp.new }
  let(:request) { Rack::MockRequest.new(middleware) }

  before do
    allow(TradeTariffFrontend).to receive(:basic_auth?).and_return(auth_enabled)
  end

  context 'when basic auth is enabled' do
    let(:auth_enabled) { true }
    let(:credentials) { "Basic #{['test:test'].pack('m*')}" }

    it 'returns 401 when unauthenticated' do
      response = request.get('/foo/1', 'CONTENT_TYPE' => 'text/plain')
      expect(response.status).to eq(401)
    end

    it 'returns 200 when authenticated' do
      response = request.get('/foo/1', 'CONTENT_TYPE' => 'text/plain', 'HTTP_AUTHORIZATION' => credentials)
      expect(response.status).to eq(200)
    end

    it 'returns 401 when on the /healthcheck path' do
      response = request.get('/healthcheck', 'CONTENT_TYPE' => 'text/plain')
      expect(response.status).to eq(200)
    end
  end

  context 'when basic auth is disabled' do
    let(:auth_enabled) { false }

    before do
      request.get('/foo/1', 'CONTENT_TYPE' => 'text/plain')
    end

    it 'returns 200' do
      response = request.get('/foo/1', 'CONTENT_TYPE' => 'text/plain')
      expect(response.status).to eq(200)
    end
  end
end
