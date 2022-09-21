require 'spec_helper'

RSpec.describe 'rules_of_origin/wizard_link', type: :view do
  subject { render_page && rendered }

  let :render_page do
    render 'rules_of_origin/wizard_link', country_code: 'JP',
                                          commodity_code: '1234567890',
                                          import_trade_summary: build(:import_trade_summary)
  end

  let(:step) { RulesOfOrigin::Wizard.steps.first }
  let(:prefix) { step.model_name.singular }

  it { is_expected.to have_css 'h3' }
  it { is_expected.to have_css 'p', text: /trade fulfils/ }
  it { is_expected.to have_css %(form[action="#{rules_of_origin_step_path('1234567890', 'JP', step.key)}"]) }
  it { is_expected.to have_css %(form input[name="#{prefix}[commodity_code]"][value="1234567890"]) }
  it { is_expected.to have_css %(form input[name="#{prefix}[country_code]"][value="JP"]) }
  it { is_expected.to have_css %(form input[name="#{prefix}[service]"][value="uk"]) }
end
