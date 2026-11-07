require 'spec_helper'

RSpec.describe 'Image descriptions', :aggregate_failures, type: :request do
  let(:id) { 'aabbccdd-1234-4567-8901-aabbccddeeff' }
  let(:headers) { { 'content-type' => 'application/json' } }
  let(:image) { Rack::Test::UploadedFile.new(file.path, 'image/png') }
  let(:file) do
    Tempfile.new(['product', '.png']).tap do |item|
      item.write('synthetic image bytes')
      item.rewind
    end
  end

  before do
    enable_feature(:image_descriptions)
    stub_api_request('image_descriptions', :post, internal: true).to_return(
      status: 202, headers:, body: { id:, status: 'queued' }.to_json,
    )
  end

  after { file.close! }

  def upload
    post '/search/image-descriptions', params: { image: }
    expect(response).to have_http_status(:accepted)
    response.parsed_body
  end

  it 'filters image uploads from parameter logs' do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    expect(filter.filter('image' => image)).to eq('image' => '[FILTERED]')
  end

  it 'uploads bytes once and returns a no-store session-bound polling URL' do
    accepted = upload
    expect(accepted).to include('status' => 'queued', 'poll_url' => a_string_including("/search/image-descriptions/#{id}?token="))
    expect(accepted).not_to have_key('id')
    expect(response.headers['Cache-Control']).to eq('no-store')
    expect(WebMock).to(have_requested(:post, %r{#{internal_api_path}/image_descriptions$}).with { |request|
      env = Rack::MockRequest.env_for('/', method: 'POST', input: request.body, 'CONTENT_TYPE' => request.headers.fetch('Content-Type'))
      uploaded = ActionDispatch::Request.new(env).request_parameters.fetch('image')
      uploaded.is_a?(ActionDispatch::Http::UploadedFile) && uploaded.read == 'synthetic image bytes'
    }.once)
  end

  it 'returns editable description data only to the originating session' do
    accepted = upload
    stub_api_request("image_descriptions/#{id}", internal: true).to_return(
      status: 200, headers:, body: { id:, status: 'completed', description: 'A cotton shirt.', uncertainties: ['Check the fibre content.'] }.to_json,
    )
    get accepted.fetch('poll_url')
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq('status' => 'completed', 'description' => 'A cotton shirt.', 'uncertainties' => ['Check the fibre content.'])
    expect(response.headers['Cache-Control']).to eq('no-store')

    other_browser = ActionDispatch::Integration::Session.new(Rails.application)
    other_browser.get accepted.fetch('poll_url')
    expect(other_browser.response).to have_http_status(:not_found)
    expect(WebMock).to have_requested(:get, %r{#{internal_api_path}/image_descriptions/#{id}$}).once
  end

  it 'rejects an unsigned or changed ID without reading the backend' do
    get "/search/image-descriptions/#{id}", params: { token: 'invalid' }
    expect(response).to have_http_status(:not_found)
    accepted = upload
    get accepted.fetch('poll_url').sub(id, SecureRandom.uuid)
    expect(response).to have_http_status(:not_found)
    expect(WebMock).not_to have_requested(:get, %r{#{internal_api_path}/image_descriptions/})
  end

  it 'rejects an expired grant' do
    accepted = upload
    travel 6.minutes do
      get accepted.fetch('poll_url')
      expect(response).to have_http_status(:not_found)
    end
    expect(WebMock).not_to have_requested(:get, %r{#{internal_api_path}/image_descriptions/})
  end

  it 'does not accept uploads when the feature is disabled' do
    disable_feature(:image_descriptions)
    post '/search/image-descriptions', params: { image: }
    expect(response).to have_http_status(:not_found)
    expect(WebMock).not_to have_requested(:post, %r{#{internal_api_path}/image_descriptions$})
  end

  it 'accepts uploads in production when enabled' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    post '/search/image-descriptions', params: { image: }
    expect(response).to have_http_status(:accepted)
  end

  it 'is unavailable in XI' do
    post '/xi/search/image-descriptions', params: { image: }
    expect(response).to have_http_status(:not_found)
  end

  ['a path is not an upload', { tempfile: '/etc/passwd' }, nil].each do |invalid|
    it "rejects a non-file parameter (#{invalid.inspect})" do
      post '/search/image-descriptions', params: { image: invalid }
      expect(response).to have_http_status(:unprocessable_content)
      expect(WebMock).not_to have_requested(:post, %r{#{internal_api_path}/image_descriptions$})
    end
  end

  it 'rejects oversized files before a backend call' do
    file.truncate(GuidedSearch::ImageDescription::MAX_BYTES + 1)
    post '/search/image-descriptions', params: { image: }
    expect(response).to have_http_status(:content_too_large)
    expect(WebMock).not_to have_requested(:post, %r{#{internal_api_path}/image_descriptions$})
  end

  it 'rejects empty files before a backend call' do
    file.truncate(0)
    post '/search/image-descriptions', params: { image: }
    expect(response).to have_http_status(:unprocessable_content)
    expect(WebMock).not_to have_requested(:post, %r{#{internal_api_path}/image_descriptions$})
  end

  [413, 415, 422, 503].each do |status|
    it "maps backend #{status} to a safe error without leaking provider details" do
      stub_api_request('image_descriptions', :post, internal: true).to_return(
        status:, headers:, body: { errors: [{ detail: 'private provider detail' }] }.to_json,
      )
      post '/search/image-descriptions', params: { image: }
      expect(response).to have_http_status(status)
      expect(response.parsed_body.fetch('error')).not_to include('private')
    end
  end

  it 'does not resubmit an ambiguous failed upload' do
    stub_api_request('image_descriptions', :post, internal: true).to_timeout
    post '/search/image-descriptions', params: { image: }
    expect(response).to have_http_status(:service_unavailable)
    expect(WebMock).to have_requested(:post, %r{#{internal_api_path}/image_descriptions$}).once
  end

  it 'keeps provider failure details private' do
    accepted = upload
    stub_api_request("image_descriptions/#{id}", internal: true).to_return(
      status: 200, headers:, body: { id:, status: 'failed', error: 'private provider detail' }.to_json,
    )
    get accepted.fetch('poll_url')
    expect(response.parsed_body).to eq('status' => 'failed', 'error' => ImageDescriptionsController::RECOVERY_MESSAGE)
  end

  it 'requires CSRF protection for image uploads' do
    previous = ImageDescriptionsController.allow_forgery_protection
    ImageDescriptionsController.allow_forgery_protection = true
    post '/search/image-descriptions', params: { image: }
    expect(response).to have_http_status(:unprocessable_content)
    expect(WebMock).not_to have_requested(:post, %r{#{internal_api_path}/image_descriptions$})
  ensure
    ImageDescriptionsController.allow_forgery_protection = previous
  end
end
