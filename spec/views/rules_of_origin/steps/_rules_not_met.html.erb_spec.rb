require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_rules_not_met', type: :view do
  include_context 'with rules of origin form step',
                  'rules_not_met',
                  :insufficient_processing

  it { is_expected.to have_css 'span.govuk-caption-xl', text: %r{(Im|Ex)porting.* #{wizardstore['commodity_code']}.*Japan} }
  it { is_expected.to have_css 'h1', text: /not met/i }
  it { is_expected.to have_css '.govuk-panel--confirmation .govuk-panel__body', count: 1 }
  it { is_expected.to have_css '.govuk-panel__body', text: %r{#{schemes.first.title}} }
  it { is_expected.to have_css '.govuk-panel + .tariff-markdown *', text: %r{#{schemes.first.title}} }
  it { is_expected.to have_css '#tolerances-section p a' }
  it { is_expected.to have_css '#sets-section h3' }
  it { is_expected.to have_css '#sets-section p' }
  it { is_expected.to have_css '#sets-section details' }
  it { is_expected.to have_css '#cumulation-section h3' }
  it { is_expected.to have_css '#cumulation-section a' }
  it { is_expected.to have_css '#whats-next-section.panel--coloured strong' }
  it { is_expected.to have_css '#whats-next-section a', count: 2 }
  it { is_expected.not_to have_css '#next-steps' }
end
