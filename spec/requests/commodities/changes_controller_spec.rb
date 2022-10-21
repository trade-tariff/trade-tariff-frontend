require 'spec_helper'

RSpec.describe Commodities::ChangesController, type: :request do
  describe 'GET #index' do
    subject(:do_request) do
      VCR.use_cassette('commodities_changes#index') do
        get '/commodities/0101210000/changes'
      end

      response
    end

    it { is_expected.to have_http_status(:ok) }
    it { expect(do_request.content_type).to eq 'application/atom+xml; charset=utf-8' }
    it { expect(do_request.body).to match 'measure changes feed for Commodity 0101210000' }
  end
end
