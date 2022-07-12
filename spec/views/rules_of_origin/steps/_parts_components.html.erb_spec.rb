require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_parts_components', type: :view do
  include_context 'with rules of origin form step',
                  'parts_components',
                  :originating

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /originating/i }
  it { is_expected.to have_css 'h1', text: /parts or components/ }
  it { is_expected.to have_css 'p strong', text: 'cumulation rules' }
  it { is_expected.to have_css 'h3.govuk-heading-s', text: %r{Cumulation.*#{schemes.first.title}} }
  it { is_expected.to have_css '.govuk-inset-text', text: %r{#{schemes.first.title}} }
  it { is_expected.to have_css 'p strong', text: 'Bilateral cumulation' }
  it { is_expected.to have_css 'figure img[src*="roo_wizard/bilateral"]' }
  it { is_expected.to have_css 'figure figcaption' }
  it { is_expected.to have_css 'details.govuk-details summary', text: %r{cumulation.*#{schemes.first.title}} }
  it { is_expected.to have_css 'details.govuk-details div.govuk-details__text' }
  it { is_expected.to have_css 'h3.govuk-heading-s', text: /Next step/ }
  it { is_expected.to have_css '#next-step p', text: %r{#{schemes.first.title}} }
end
