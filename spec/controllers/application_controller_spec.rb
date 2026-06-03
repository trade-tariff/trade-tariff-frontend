require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Hari Seldon'
    end
  end

  describe 'GET #index' do
    subject(:response) { get :index }

    let(:expected_cache_control) do
      %w[
        max-age=0
        public
        must-revalidate
        proxy-revalidate
      ].join(', ')
    end

    it { expect(response.headers['Cache-Control']).to eq(expected_cache_control) }
    it { expect(response.headers['Pragma']).to eq('no-cache') }
    it { expect(response.headers['Expires']).to eq('-1') }
  end

  describe '#append_info_to_payload' do
    it 'adds frontend and search request ids to the logging payload' do
      request.request_id = 'frontend-request-id'
      controller.instance_variable_set(:@search, Search.new(q: '94036099', request_id: 'search-request-id'))

      payload = {}
      controller.send(:append_info_to_payload, payload)

      expect(payload).to include(
        request_id: 'frontend-request-id',
        search_request_id: 'search-request-id',
      )
    end
  end
end
