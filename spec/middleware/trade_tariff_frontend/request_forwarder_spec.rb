require 'spec_helper'

RSpec.describe TradeTariffFrontend::RequestForwarder do
  let(:app)            { ->(env) { [200, env, 'app'] } }
  let(:host)           { TradeTariffFrontend::ServiceChooser.api_host }
  let(:request_path)   { '/sections/1' }
  let(:request_params) { '?page=2' }

  let(:response_body) { 'example' }

  let(:middleware) do described_class.new(host:) end

  before do
    allow(TradeTariffFrontend::ServiceChooser).to receive(:api_client_with_forwarding).and_call_original
  end

  around do |example|
    # These specs use WebMock
    VCR.turned_off do
      example.run
    end
  end

  it 'picks a reusable client' do
    stub_request(:get, "#{host}#{request_path}")

    middleware.call env_for(request_path)

    expect(TradeTariffFrontend::ServiceChooser).to have_received(:api_client_with_forwarding)
  end

  it 'forwards response from upstream backend host for GETs' do
    stub_request(:get, "#{host}#{request_path}")
      .with(headers: { 'Accept' => 'application/vnd.uktt.sections' })
      .to_return(
        status: 200,
        body: response_body,
        headers: { 'Content-Length' => response_body.size },
      )

    status, env, body = middleware.call env_for(request_path)

    expect(body).to include response_body
  end

  it 'forwards response from upstream backend host for HEADs' do
    stub_request(:head, "#{host}#{request_path}")
      .with(headers: { 'Accept' => 'application/vnd.uktt.sections' })
      .to_return(
        status: 200,
        body: '',
        headers: { 'Content-Length' => 0 },
      )

    status, env, body = middleware.call env_for(request_path, method: :head)

    expect(status).to eq 200
    expect(body).to eq ['']
  end

  it 'forwards response status code from upstream backend host' do
    stub_request(:get, "#{host}#{request_path}")
      .with(headers: { 'Accept' => 'application/vnd.uktt.sections' })
      .to_return(
        status: 404,
        body: 'Not Found',
        headers: { 'Content-Length' => 'Not Found'.size },
      )

    status, env, body = middleware.call env_for(request_path)

    expect(status).to eq 404
  end

  it 'forwards allowed headers from upstream backend host' do
    stub_request(:get, "#{host}#{request_path}")
      .with(headers: { 'Accept' => 'application/vnd.uktt.sections' })
      .to_return(
        status: 200,
        body: response_body,
        headers: {
          'Content-Length' => response_body.size,
          'Content-Type' => 'text/html',
        },
      )

    status, env, body = middleware.call env_for(request_path)

    expect(env['Content-Type']).to eq 'text/html'
  end

  it 'does not forward non-allowed headers from upstream backend host' do
    stub_request(:get, "#{host}#{request_path}")
      .with(headers: { 'Accept' => 'application/vnd.uktt.sections' })
      .to_return(
        status: 200,
        body: response_body,
        headers: {
          'Content-Length' => response_body.size,
          'X-UA-Compatible' => 'IE=9',
        },
      )

    status, env, body = middleware.call env_for(request_path)

    expect(env['X-UA-Compatible']).to be_blank
  end

  it 'only accepts GET requests' do
    status, env, body = middleware.call env_for(request_path, method: :post)

    expect(status).to eq 405 # METHOD NOT ALLOWED
    expect(body).to be_blank
  end

  it 'forwards request params' do
    request_uri = request_path + request_params

    stub_request(:get, "#{host}#{request_uri}")
      .with(headers: { 'Accept' => 'application/vnd.uktt.sections' })
      .to_return(
        status: 200,
        body: response_body,
        headers: { 'Content-Length' => response_body.size },
      )

    status, env, body = middleware.call env_for(request_uri)

    expect(status).to eq(200)
  end

  context 'when a service prefix is included in the path' do
    let(:request_path) { '/xi/sections/1' }

    it 'removes the service prefix' do
      TradeTariffFrontend::ServiceChooser.service_choice = 'xi'

      stub_request(:get, "#{host}/sections/1")
        .with(headers: { 'Accept' => 'application/vnd.uktt.sections' })
        .to_return(
          status: 200,
          body: response_body,
          headers: {
            'Content-Length' => response_body.size,
            'X-UA-Compatible' => 'IE=9',
          },
        )

      status, env, body = middleware.call env_for(request_path)

      expect(env['X-UA-Compatible']).to be_blank

      TradeTariffFrontend::ServiceChooser.service_choice = nil
    end
  end

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end
end
