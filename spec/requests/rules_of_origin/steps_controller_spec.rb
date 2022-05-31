require 'spec_helper'

RSpec.describe RulesOfOrigin::StepsController, type: :request do
  subject { response }

  let(:first_step) { RulesOfOrigin::Wizard.steps.first }
  let(:second_step) { RulesOfOrigin::Wizard.steps.second } # first is Init step
  let(:initial_params) { { country_code: 'JP', commodity_code: '6004100091' } }

  describe 'GET #index' do
    before { get rules_of_origin_steps_path }

    it { is_expected.to redirect_to rules_of_origin_step_path(first_step.key) }
  end

  describe 'GET #show for first step' do
    before { get rules_of_origin_step_path(first_step.key) }

    it { is_expected.to redirect_to find_commodity_path }
  end

  describe 'GET #show' do
    before do
      stub_api_request('/geographical_areas/JP').and_return \
        jsonapi_response :geographical_area,
                         attributes_for(:geographical_area, description: 'Japan')

      put rules_of_origin_step_path(first_step.key), params: {
        first_step.model_name.singular => initial_params,
      }
    end

    context 'with valid step' do
      before { get rules_of_origin_step_path second_step.key }

      it { is_expected.to have_http_status :success }
      it { is_expected.to have_attributes body: /into the UK or into Japan/ }
    end

    context 'with an invalid step' do
      before { get rules_of_origin_step_path :invalid }

      it { is_expected.to have_http_status :not_found }
    end

    context 'with changed service' do
      before { get "/xi#{rules_of_origin_step_path(second_step.key)}" }

      it { is_expected.to redirect_to commodity_path('6004100091', country: 'JP', anchor: 'rules-of-origin') }
    end
  end
end
