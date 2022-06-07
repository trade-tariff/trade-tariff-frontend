require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_import_export', type: :view do
  include_context 'with rules of origin form step', 'import_export'

  it { is_expected.to have_css 'h1', text: /importing goods into the UK or into Japan/ }
  it { is_expected.to have_css 'input[type="radio"]', count: 2 }
  it { is_expected.to have_css 'label', text: /into the UK from Japan/ }

  context 'with invalid submission' do
    before { current_step.validate }

    it { is_expected.to have_css '.govuk-error-message', text: /Select.*the UK.*Japan/i }
  end
end
