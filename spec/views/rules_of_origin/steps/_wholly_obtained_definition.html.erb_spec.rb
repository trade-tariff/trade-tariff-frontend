require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_wholly_obtained_defintion', type: :view do
  include_context 'with rules of origin form step',
                  'wholly_obtained_definition',
                  :originating

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /originating/i }
  it { is_expected.to have_css 'h1', text: %r{wholly obtained.+#{schemes.first.title}} }
  xit { is_expected.to have_css 'p.govuk-body-l', text: %r{wholly obtained.*Japan.*#{schemes.first.title}} }
  xit { is_expected.to have_css '.tariff-markdown ol li' }
  it { is_expected.to have_css 'details.govuk-details summary' }
  it { is_expected.to have_css 'details.govuk-details div.govuk-details__text' }
  it { is_expected.to have_css '.tariff-markdown p', text: %r{#{schemes.first.title}} }
end
