require 'spec_helper'

RSpec.describe OutOfServiceController, type: :request do
  subject(:rendered) { make_request && response }

  let(:json_response) { JSON.parse(rendered.body) }

  shared_examples 'a json error response' do |status_code, message|
    it { is_expected.to have_http_status status_code }
    it { is_expected.to have_attributes media_type: 'application/json' }
    it { expect(json_response).to include 'error' => message }
  end

  describe 'GET /api/v1/foo' do
    let(:make_request) { get '/api/v1/foo' }

    it_behaves_like 'a json error response', 503, 'api-disabled'
  end
end
