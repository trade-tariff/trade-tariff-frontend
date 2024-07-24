require 'spec_helper'

RSpec.describe GreenLanes::ApplicableExemptionsController, type: :request,
                                                           vcr: { cassette_name: 'green_lanes/applicable_exemptions', record: :new_episodes } do
  subject { make_request && response }

  let(:category) { '1' }
  let(:commodity_code) { '4114109000' }
  let(:country_of_origin) { 'UA' }
  let(:moving_date) { '2024-05-29' }

  describe 'GET #new' do
    let(:make_request) do
      get new_green_lanes_applicable_exemptions_path(category:,
                                                     commodity_code:,
                                                     country_of_origin:,
                                                     moving_date:)
    end

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }

    it { is_expected.to render_template(:cat_1_exemptions_questions) }
  end

  describe 'POST #create' do
    let(:make_request) do
      post green_lanes_applicable_exemptions_path, params: {
        exemptions: {
          category_assessment_822: ['', 'Y922'],
          category_assessment_34: ['', 'Y997'],
          category_assessment_82: ['', 'none'],
        },
        category:,
        commodity_code:,
        country_of_origin:,
        moving_date:,
      }
    end

    it { is_expected.to have_http_status :redirect }
    it { is_expected.to redirect_to('/green_lanes/results/1?commodity_code=4114109000&country_of_origin=UA&moving_date=2024-05-29') }
  end
end
