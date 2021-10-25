require 'spec_helper'

RSpec.describe BrowseSectionsController, type: :request do
  subject { response }

  let(:json) { JSON.parse(response.body) }

  describe 'GET /browse' do
    before do
      VCR.use_cassette('geographical_areas#countries') do
        VCR.use_cassette('sections#index') do
          get browse_sections_path
        end
      end
    end

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
