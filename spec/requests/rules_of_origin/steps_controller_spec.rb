require 'spec_helper'

RSpec.describe RulesOfOrigin::StepsController, type: :request do
  subject { response }

  let(:first_step) { RulesOfOrigin::Wizard.steps.first.key }
  let(:initial_params) { { country_code: 'JP', commodity_code: '6004100091' } }

  describe 'GET #index' do
    before { get rules_of_origin_steps_path, params: initial_params }

    it { is_expected.to redirect_to rules_of_origin_step_path(first_step) }
  end

  describe 'GET #show' do
    before do
      get rules_of_origin_steps_path, params: initial_params
      follow_redirect!
    end

    context 'with valid step' do
      before { get rules_of_origin_step_path first_step }

      it { is_expected.to have_http_status :success }
      it { is_expected.to have_attributes body: /into the UK or into Japan/ }
    end

    context 'with an invalid step' do
      before { get rules_of_origin_step_path :invalid }

      it { is_expected.to have_http_status :not_found }
    end

    context 'with changed service' do
      before { get "/xi#{rules_of_origin_step_path(first_step)}" }

      it { is_expected.to redirect_to commodity_path('6004100091', country: 'JP', anchor: 'rules-of-origin') }
    end
  end
end
