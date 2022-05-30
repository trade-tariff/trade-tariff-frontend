require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/show', type: :view do
  subject { render && rendered }

  include_context 'with wizard store'
  include_context 'with govuk form builder'

  before do
    stub_api_request('/geographical_areas/JP').and_return \
      jsonapi_response :geographical_area,
                       attributes_for(:geographical_area, description: 'Japan')
    allow(view).to receive(:wizard).and_return wizard
    allow(view).to receive(:current_step).and_return current_step
    allow(view).to receive(:step_path).and_return \
      rules_of_origin_step_path(current_step.key)
  end

  let(:wizard) { RulesOfOrigin::Wizard.new wizardstore, 'import_export' }
  let(:current_step) { wizard.find_current_step }

  let :backingstore do
    { service: 'uk', country_code: 'JP', commodity_code: '6004100091' }.stringify_keys
  end

  it { is_expected.to have_css 'section', count: 1 }
  it { is_expected.to have_css '.govuk-back-link' }
  it { is_expected.to have_css 'h1', text: /importing goods into the UK or into Japan/ }
  it { is_expected.to have_css 'input[type="radio"]', count: 2 }
  it { is_expected.to have_css 'label', text: /into the UK from Japan/ }
  it { is_expected.to have_css 'button', text: 'Continue' }

  context 'with invalid submission' do
    before { current_step.validate }

    it { is_expected.to have_css '.govuk-error-summary' }
    it { is_expected.to have_css '.govuk-error-message', text: /Choose/i }
  end
end
