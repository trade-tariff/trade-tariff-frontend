require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/show', type: :view do
  subject { render && rendered }

  include_context 'with rules of origin store'

  before do
    allow(view).to receive(:wizard).and_return wizard
    allow(view).to receive(:current_step).and_return current_step
    allow(view).to receive(:step_path).and_return \
      rules_of_origin_step_path(current_step.key)
  end

  let(:wizard) { RulesOfOrigin::Wizard.new wizardstore, 'import_export' }
  let(:current_step) { wizard.find_current_step }

  it { is_expected.to have_css 'section', count: 1 }
  it { is_expected.to have_css '.govuk-back-link' }
  it { is_expected.to have_css 'button', text: 'Continue' }

  context 'with invalid submission' do
    before { current_step.validate }

    it { is_expected.to have_css '.govuk-error-summary' }
  end
end
