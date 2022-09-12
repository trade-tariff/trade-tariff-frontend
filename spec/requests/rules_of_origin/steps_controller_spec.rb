require 'spec_helper'

RSpec.describe RulesOfOrigin::StepsController, type: :request do
  subject { response }

  let(:first_step_path) { rules_of_origin_step_path(commodity_code, country_code, 'start') }
  let(:second_step_path) { rules_of_origin_step_path(commodity_code, country_code, 'scheme') } # first is Start/init step
  let(:return_path) { commodity_path(commodity_code, country: country_code, anchor: 'rules-of-origin') }
  let(:commodity_code) { '6004100091' }
  let(:country_code) { 'JP' }

  describe 'GET #index' do
    before { get rules_of_origin_steps_path(commodity_code, country_code) }

    it { is_expected.to redirect_to first_step_path }
  end

  describe 'GET #show without initialized session' do
    context 'with first step' do
      before { get first_step_path }

      it { is_expected.to redirect_to return_path }
    end

    context 'with later step' do
      before { get second_step_path }

      it { is_expected.to redirect_to return_path }
    end

    context 'with missing params' do
      before { get rules_of_origin_step_path(' ', ' ', 'start') }

      it { is_expected.to redirect_to find_commodity_path }
    end
  end

  describe 'GET #show' do
    include_context 'with rules of origin store'

    before do
      patch first_step_path, params: {
        RulesOfOrigin::Wizard.steps.first.model_name.singular => {
          country_code:,
          commodity_code:,
          service: 'uk',
        },
      }
    end

    context 'with valid step' do
      before { get second_step_path }

      it { is_expected.to have_http_status :success }
      it { is_expected.to have_attributes body: /Details of your trade/ }
    end

    context 'with changed service' do
      before { get "/xi#{second_step_path}" }

      it { is_expected.to redirect_to return_path }
    end
  end
end
