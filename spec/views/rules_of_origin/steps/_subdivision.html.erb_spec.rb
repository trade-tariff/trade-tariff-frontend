require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_subdivision', type: :view do
  include_context 'with rules of origin form step', 'subdivision'

  before do
    allow(Commodity).to receive(:find).with(wizardstore['commodity_code'])
                                      .and_return(commodity)
  end

  let :commodity do
    build :commodity, commodity_code: wizardstore['commodity_code']
  end

  let :schemes do
    build_list :rules_of_origin_scheme, 1, countries: [country.id], articles:, rule_sets:
  end

  let(:rule_sets) { attributes_for_pair :rules_of_origin_rule_set, :subdivided }

  it { is_expected.to have_css 'form h1', text: /more information/ }
  it { is_expected.to have_css '.govuk-hint', text: /commodity #{wizardstore['commodity_code']}/i }
  it { is_expected.to have_css 'fieldset input[type="radio"]' }
  it { is_expected.to have_css 'input[type=radio] + label', text: schemes.first.rule_sets.first.subdivision }
  it { is_expected.to have_css 'details.govuk-details summary' }
  it { is_expected.to have_css 'button[type="submit"]', text: 'Continue' }

  context 'with invalid submission' do
    before { current_step.validate }

    it { is_expected.to have_css '.govuk-error-message', text: /Select the type/i }
  end
end
