require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_origin_requirements_met', type: :view do
  include_context 'with rules of origin form step',
                  'proofs_of_origin',
                  :wholly_obtained

  it { is_expected.to have_css 'span.govuk-caption-xl', text: %r{(Im|Ex)porting.* #{wizardstore['commodity_code']}.*Japan.*UK} }
  it { is_expected.to have_css 'h1', text: /valid proofs/i }
  it { is_expected.to have_css 'p', text: /preferential tariff/ }
  it { is_expected.to have_css '#proofs-overview h3', text: /overview/ }
  it { is_expected.to have_css '#proofs-overview p', text: /provide proof/ }
  it { is_expected.to have_css '#proofs-overview a', count: 2 }
  it { is_expected.to have_css 'h3', text: /Next/i }
  it { is_expected.to have_css '#next-steps a', count: 2 }
end
