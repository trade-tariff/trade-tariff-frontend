require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_wholly_obtained', type: :view do
  include_context 'with rules of origin form step', 'wholly_obtained'

  it { is_expected.to have_css 'h1', text: /wholly obtained in Japan/ }
  it { is_expected.to have_css 'input[type="radio"]', count: 2 }
  it { is_expected.to have_css 'label', text: /obtained.+Japan/ }
  it { is_expected.to have_css '.govuk-hint a' }

  context 'with invalid submission' do
    before { current_step.validate }

    it { is_expected.to have_css '.govuk-error-message', text: /Select.*obtained.*Japan/i }
  end
end
