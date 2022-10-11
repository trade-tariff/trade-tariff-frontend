require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_product_specific_rules', type: :view do
  include_context 'with rules of origin form step', 'product_specific_rules'

  before do
    allow(Commodity).to receive(:find).with(wizardstore['commodity_code'])
                                      .and_return(commodity)
  end

  let :commodity do
    build :commodity, commodity_code: wizardstore['commodity_code']
  end

  it { is_expected.to have_css 'form h1', text: /product-specific rules/ }
  it { is_expected.to have_css '.govuk-hint', text: /select an option/i }
  it { is_expected.to have_css 'fieldset input[type="radio"]' }
  it { is_expected.to have_css 'details.govuk-details summary', count: 2 }
  it { is_expected.to have_css 'button[type="submit"]', text: 'Continue' }

  context 'with invalid submission' do
    before do
      current_step.rule = 'invalid'
      current_step.validate
    end

    it { is_expected.to have_css '.govuk-error-message', text: /Select whether/i }
  end

  context 'with markdown in rule' do
    let :schemes do
      build_list :rules_of_origin_scheme, 1,
                 countries: [country.id],
                 rule_sets:,
                 articles:
    end

    let(:rule_sets) { attributes_for_list :rules_of_origin_rule_set, 1, rules: }

    let :rules do
      attributes_for_list :rules_of_origin_v2_rule, 1,
                          rule: '[Chapter&nbsp;1](/some/where)'
    end

    it { is_expected.to have_css 'fieldset label a', text: /Chapter.*1/ }
  end
end
