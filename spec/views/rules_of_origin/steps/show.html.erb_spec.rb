require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/show', type: :view do
  subject { render && rendered }

  include_context 'with rules of origin store'

  before do
    allow(view).to receive_messages(wizard: wizard, current_step: current_step, step_path: rules_of_origin_step_path('1234567890', 'JP', current_step.key), return_to_commodity_path: '/')
  end

  let(:wizard) { RulesOfOrigin::Wizard.new wizardstore, 'import_export' }
  let(:current_step) { wizard.find_current_step }

  it { is_expected.to have_css 'section', count: 1 }
  it { is_expected.to have_css '.govuk-back-link' }
  it { is_expected.to have_css 'button', text: 'Continue' }
  it { is_expected.to have_css '#step-by-step-navigation' }

  context 'with invalid submission' do
    before { current_step.validate }

    it { is_expected.to have_css '.govuk-error-summary' }
  end

  context 'with step not shown in sidebar' do
    let(:wizard) { RulesOfOrigin::Wizard.new wizardstore, 'import_only' }

    it { is_expected.not_to have_css '#step-by-step-navigation' }
  end
end
