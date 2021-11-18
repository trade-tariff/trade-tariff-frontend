require 'spec_helper'

RSpec.describe FindCommoditiesController, type: :request do
  subject { response }

  describe 'GET #show' do
    include_context 'with latest news stubbed'

    before { get find_commodity_path }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
