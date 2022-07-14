require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_proof_requirements', type: :view do
  include_context 'with rules of origin form step',
                  'proof_requirements',
                  :wholly_obtained

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /obtaining and verifying/i }
  it { is_expected.to have_css 'h1', text: /Requirements.*Japan/ }
  it { is_expected.to have_css 'p', text: %r{processes.*#{schemes.first.title}} }
end
