require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_scheme', type: :view do
  include_context 'with rules of origin form step', 'scheme'

  let :schemes do
    build_pair :rules_of_origin_scheme, countries: [country.id]
  end

  it { is_expected.to have_css 'h1', text: /agreement for trading with Japan/ }
  it { is_expected.to have_css '.govuk-hint', text: /advantage of preferential imports.*Japan/m }
  it { is_expected.to have_css 'input[type="radio"]', count: 2 }
  it { is_expected.to have_css 'label', text: schemes.first.title }
  it { is_expected.to have_css 'label', text: schemes.second.title }

  context 'with invalid submission' do
    before { current_step.validate }

    it { is_expected.to have_css '.govuk-error-message', text: /Select an agreement/i }
  end
end
