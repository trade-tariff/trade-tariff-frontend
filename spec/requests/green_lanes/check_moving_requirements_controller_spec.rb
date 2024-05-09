require 'spec_helper'

RSpec.describe CheckMovingRequirementsController, type: :request do
  subject { make_request && response }

  before do
    allow(GreenLanes::CategoryAssessmentSearch).to receive(:country_options).and_return([])
    allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return(true)
  end

  describe 'GET #start' do
    let(:make_request) do
      get start_check_moving_requirements_path
    end

    it { is_expected.to have_http_status :ok }
  end

  describe 'when the feature "check moving requirements" is disabled' do
    let(:make_request) do
      get start_check_moving_requirements_path
    end

    before do
      allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return(false)
    end

    it { is_expected.to have_http_status :not_found }

    it { is_expected.to render_template 'errors/not_found' }
  end

  describe 'GET #edit' do
    let(:make_request) do
      get edit_check_moving_requirements_path
    end

    it { is_expected.to have_http_status :ok }
  end

  describe 'PUT #update' do
    context 'when all the form values are correct' do
      let(:make_request) do
        put check_moving_requirements_path, params: {
          check_moving_requirements_form: {
            commodity_code: '1234567890',
            country_of_origin: 'IT',
            'moving_date(3i)' => '3',
            'moving_date(2i)' => '2',
            'moving_date(1i)' => '2022',
          },
        }
      end

      it { is_expected.to redirect_to(result_check_moving_requirements_path) }
    end

    context 'when a value is missing or incorrect' do
      let(:make_request) do
        put check_moving_requirements_path, params: {
          check_moving_requirements_form: {
            commodity_code: '',
            country_of_origin: 'IT',
            'moving_date(3i)' => '3',
            'moving_date(2i)' => '2',
            'moving_date(1i)' => '2022',
          },
        }
      end

      it { is_expected.to have_http_status :unprocessable_entity }
    end
  end
end
