require 'spec_helper'

RSpec.describe Chapters::ChangesController, type: :request do
  describe 'GET #index' do
    before do
      VCR.use_cassette('chapters_changes#index') do
        get '/chapters/01/changes'
      end
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response.content_type).to eq 'application/atom+xml; charset=utf-8' }
    it { expect(response.body).to match 'measure changes feed for Chapter 01' }
  end
end
