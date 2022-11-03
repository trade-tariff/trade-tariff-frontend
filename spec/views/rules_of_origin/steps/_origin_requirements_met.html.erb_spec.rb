require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_origin_requirements_met', type: :view do
  include_context 'with rules of origin form step',
                  'origin_requirements_met',
                  :wholly_obtained

  it { is_expected.to have_css 'span.govuk-caption-xl', text: %r{(Im|Ex)porting.* #{wizardstore['commodity_code']}.*Japan.*UK} }
  it { is_expected.to have_css 'h1', text: /Product-specific rules met/i }
  it { is_expected.to have_css '.govuk-panel--confirmation .govuk-panel__body', count: 1 }
  it { is_expected.to have_css '.govuk-panel__body', text: %r{#{schemes.first.title}} }
  it { is_expected.to have_css '#next-steps a', count: 3 }

  context 'with duty drawback available' do
    let :articles do
      attributes_for_list :rules_of_origin_article, 1, article: 'duty-drawback'
    end

    it { is_expected.to have_css '#next-steps a', count: 4 }
  end
end
