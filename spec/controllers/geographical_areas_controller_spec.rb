require 'spec_helper'

RSpec.describe GeographicalAreasController, type: :controller do
  describe 'GET show', vcr: { cassette_name: 'geographical_areas#1013' } do
    subject(:do_response) { get :show, params: { id: '1013' } }

    it { is_expected.to render_template('geographical_areas/show') }
    it { is_expected.to have_http_status(:success) }
  end
end
