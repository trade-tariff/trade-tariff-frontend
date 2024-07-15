require 'spec_helper'

RSpec.describe GreenLanes::MovingRequirementsController, type: :request do
  subject { make_request && response }

  before do
    allow(GreenLanes::CategoryAssessmentSearch).to receive(:country_options).and_return([])
    allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return(true)
  end

  describe 'GET #start' do
    let(:make_request) { get start_green_lanes_check_moving_requirements_path }

    it { is_expected.to have_http_status(:ok) }
  end

  describe 'when the feature "check moving requirements" is disabled' do
    let(:make_request) { get start_green_lanes_check_moving_requirements_path }

    before do
      allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return(false)
    end

    it { is_expected.to have_http_status(:not_found) }
    it { is_expected.to render_template('errors/not_found') }
  end

  describe 'GET #edit' do
    let(:make_request) { get edit_green_lanes_check_moving_requirements_path }

    it { is_expected.to have_http_status(:ok) }
  end

  describe 'PUT #update' do
    context 'when all the form values are correct', vcr: { cassette_name: 'green_lanes/get_goods_nomenclatures_200' } do
      let(:make_request) do
        put green_lanes_check_moving_requirements_path, params: {
          green_lanes_moving_requirements_form: {
            commodity_code: '6203000000',
            country_of_origin: 'IT',
            'moving_date(3i)' => '3',
            'moving_date(2i)' => '2',
            'moving_date(1i)' => '2022',
          },
        }
      end

      it do
        expect(make_request).to redirect_to(
          result_green_lanes_check_moving_requirements_path(
            green_lanes_moving_requirements_form: {
              commodity_code: '6203000000',
              country_of_origin: 'IT',
              moving_date: '2022-02-03',
            },
          ),
        )
      end
    end

    context 'when a value is missing or incorrect', vcr: { cassette_name: 'green_lanes/get_goods_nomenclatures_404', record: :new_episodes } do
      let(:make_request) do
        put green_lanes_check_moving_requirements_path, params: {
          green_lanes_moving_requirements_form: {
            commodity_code: '1234567890',
            country_of_origin: 'IT',
            'moving_date(3i)' => '3',
            'moving_date(2i)' => '2',
            'moving_date(1i)' => '2022',
          },
        }
      end

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  xdescribe 'GET #cat_1_exemptions_questions_edit' do
    let(:make_request) { get cat_1_questions_green_lanes_check_moving_requirements_path }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('cat_1_exemptions_questions_edit') }
  end

  xdescribe 'GET #cat_2_exemptions_questions_edit' do
    let(:make_request) { get cat_2_questions_green_lanes_check_moving_requirements_path }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('cat_2_exemptions_questions_edit') }
  end
end
