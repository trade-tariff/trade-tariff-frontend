require 'spec_helper'

RSpec.describe RulesOfOrigin::StepsController, type: :request do
  subject { response }

  let(:first_step) { RulesOfOrigin::Wizard.steps.first }
  let(:second_step) { RulesOfOrigin::Wizard.steps.second } # first is Start/init step
  let(:initial_params) { { country_code: 'JP', commodity_code: '6004100091', service: 'uk' } }
  let(:return_path) { commodity_path('6004100091', country: 'JP', anchor: 'rules-of-origin') }

  describe 'GET #index' do
    before { get rules_of_origin_steps_path }

    it { is_expected.to redirect_to rules_of_origin_step_path(first_step.key) }
  end

  describe 'GET #show without initialized session' do
    context 'with first step' do
      before { get rules_of_origin_step_path(first_step.key) }

      it { is_expected.to redirect_to find_commodity_path }
    end

    context 'with later step' do
      before { get rules_of_origin_step_path(second_step.key) }

      it { is_expected.to redirect_to find_commodity_path }
    end
  end

  describe 'GET #show' do
    include_context 'with rules of origin store'

    before do
      patch rules_of_origin_step_path(first_step.key), params: {
        first_step.model_name.singular => initial_params,
      }
    end

    context 'with valid step' do
      before { get rules_of_origin_step_path second_step.key }

      it { is_expected.to have_http_status :success }
      it { is_expected.to have_attributes body: /Details of your trade/ }
    end

    context 'with an invalid step' do
      before { get rules_of_origin_step_path :invalid }

      it { is_expected.to have_http_status :not_found }
    end

    context 'with changed service' do
      before { get "/xi#{rules_of_origin_step_path(second_step.key)}" }

      it { is_expected.to redirect_to return_path }
    end
  end
end
