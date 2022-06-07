require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_originating', type: :view do
  include_context 'with rules of origin form step', 'originating', :importing

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /originating/i }
  it { is_expected.to have_css 'h1', text: /originating.*Japan/i }
  it { is_expected.to have_css 'p.govuk-body-l', text: %r{originates.*Japan.*#{rules_of_origin.first.title}} }
  it { is_expected.to have_css '.tariff-markdown ul li' }
  it { is_expected.to have_css '.tariff-markdown p', text: %r{#{rules_of_origin.first.title}} }
end
