require 'spec_helper'

RSpec.describe Headings::ChangesController, type: :request do
  describe 'GET #index', vcr: { cassette_name: 'headings_changes#index' } do
    before { get '/headings/0101/changes' }

    it { expect(response).to have_http_status(:ok) }
    it { expect(response.content_type).to eq 'application/atom+xml; charset=utf-8' }
    it { expect(response.body).to match 'measure changes feed for Heading 0101' }
  end
end
