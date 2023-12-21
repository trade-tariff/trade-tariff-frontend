require 'spec_helper'

RSpec.describe ErrorsController, type: :request do
  subject(:rendered) { make_request && response }

  let(:json_response) { JSON.parse(rendered.body) }
  let(:body) { rendered.body }

  shared_examples 'a json error response' do |status_code, message|
    it { is_expected.to have_http_status status_code }
    it { is_expected.to have_attributes media_type: 'application/json' }
    it { expect(json_response).to include 'error' => message }
  end

  # Tests Json error responses

  describe 'GET /404.json' do
    let(:make_request) { get '/404.json' }

    it_behaves_like 'a json error response', 404, 'Resource not found'
  end

  describe 'GET /405.json' do
    let(:make_request) { get '/405.json' }

    it_behaves_like 'a json error response', 405, 'Method not allowed'
  end

  describe 'GET /406.json' do
    let(:make_request) { get '/406.json' }

    it_behaves_like 'a json error response', 406, 'Not acceptable'
  end

  describe 'GET /500.json' do
    let(:make_request) { get '/500.json' }

    it_behaves_like 'a json error response', 500, 'Internal server error'
  end

  describe 'GET /501.json' do
    let(:make_request) { get '/501.json' }

    it_behaves_like 'a json error response', 501, 'Not implemented'
  end

  describe 'GET /503.json' do
    let(:make_request) { get '/503.json' }

    it_behaves_like 'a json error response', 503, 'Maintenance mode'
  end

  # Test html error responses

  describe 'GET /404' do
    let(:make_request) { get '/404' }

    it { expect(body).to include 'Page not found' }
  end

  describe 'GET /406' do
    let(:make_request) { get '/406' }

    it { expect(body).to include 'Not acceptable' }
  end

  describe 'GET /500' do
    let(:make_request) { get '/500' }

    it { expect(body).to include 'We are experiencing technical difficulties' }
  end

  describe 'GET #not_implemented' do
    let(:make_request) { get '/501' }

    it { expect(body).to include 'Not implemented' }
  end

  describe 'GET /503' do
    let(:make_request) { get '/503' }

    it { expect(body).to include 'Maintenance' }
  end
end
