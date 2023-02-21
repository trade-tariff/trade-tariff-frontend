require 'spec_helper'

RSpec.describe Headings::ChangesController, type: :request do
  describe 'GET #index' do
    before do
      VCR.use_cassette('headings_changes#index') do
        get '/headings/0101/changes'
      end
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response.content_type).to eq 'application/atom+xml; charset=utf-8' }
    it { expect(response.body).to match 'measure changes feed for Heading 0101' }
  end
end
