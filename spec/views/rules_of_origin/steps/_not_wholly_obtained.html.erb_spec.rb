require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_not_wholly_obtained', type: :view do
  include_context 'with rules of origin form step',
                  'not_wholly_obtained',
                  :originating

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /originating/i }
  it { is_expected.to have_css 'h1', text: /not wholly obtained/ }
  it { is_expected.to have_css 'p.govuk-body-l', text: /not wholly obtained in Japan/ }
  it { is_expected.to have_css 'p', text: /product-specific rules/i }
  it { is_expected.to have_css 'details.govuk-details summary', text: /product-specific rules/ }
  it { is_expected.to have_css 'details.govuk-details div.govuk-details__text' }
  it { is_expected.to have_css 'h3.govuk-heading-s', text: /minimal operations requirements/ }
  it { is_expected.to have_css 'p', text: %r{#{schemes.first.title}} }
  it { is_expected.to have_css 'h3.govuk-heading-s', text: /including parts/i }
  it { is_expected.to have_css 'h3.govuk-heading-s', text: /Next step/ }
  it { is_expected.to have_css 'p', text: %r{cumulation.*#{schemes.first.title}} }
end
