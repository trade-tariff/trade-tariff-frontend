require 'spec_helper'

RSpec.describe RulesOfOrigin::StepsController, type: :request do
  subject { response }

  let(:first_step) { RulesOfOrigin::Wizard.steps.first.key }

  describe 'GET #index' do
    before { get rules_of_origin_steps_path }

    it { is_expected.to redirect_to rules_of_origin_step_path(first_step) }
  end

  describe 'GET #show' do
    context 'with valid step' do
      before { get rules_of_origin_step_path first_step }

      it { is_expected.to have_http_status :success }
    end

    context 'with an invalid step' do
      before { get rules_of_origin_step_path :invalid }

      it { is_expected.to have_http_status :not_found }
    end
  end
end
