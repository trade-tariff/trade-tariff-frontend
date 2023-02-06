require 'spec_helper'

RSpec.describe 'rules_of_origin/product_specific_rules/index', type: :view do
  subject { render }

  before do
    assign :commodity, commodity
    assign :schemes, schemes
  end

  let(:commodity) { build :commodity }
  let(:schemes) { build_list :rules_of_origin_scheme, 2, rule_set_count: }
  let(:rule_set_count) { 2 }

  it { is_expected.to have_link 'Back' }

  it { is_expected.to have_css 'h1', text: %r{Commodity \d{10}} }
  it { is_expected.not_to have_css '.govuk-caption-xl' }

  describe 'Contents section' do
    let(:link_id) { "#rules-for-#{schemes.first.scheme_code}" }

    it { is_expected.to have_css 'h2', text: 'Contents' }
    it { is_expected.to have_css '.gem-c-contents-list__list li', count: 2 }
    it { is_expected.to have_link schemes.first.title, href: link_id }
    it { is_expected.to have_css link_id }
  end

  describe 'Product specific rules' do
    let(:ruleset) { schemes.first.rule_sets.first }

    it { is_expected.to have_css 'h2.govuk-heading-m', count: 2 }
    it { is_expected.to have_css 'h2.govuk-heading-m', text: schemes.first.title }

    context 'with multiple rulesets' do
      it { is_expected.to have_css 'table', count: 2 }
      it { is_expected.to have_css 'tbody tr', count: 4 }
      it { is_expected.to have_css 'tbody td', count: 12 }

      it { is_expected.to have_css 'td', text: ruleset.heading }
      it { is_expected.to have_css 'td', text: ruleset.subdivision }
      it { is_expected.to have_css 'td', text: %r{#{ruleset.rules.first.rule}} }
    end

    context 'with only 1 ruleset' do
      let(:rule_set_count) { 1 }

      it { is_expected.to have_css 'table', count: 2 }
      it { is_expected.to have_css 'tbody tr', count: 2 }
      it { is_expected.to have_css 'tbody td', count: 4 }

      it { is_expected.to have_css 'td', text: ruleset.heading }
      it { is_expected.to have_css 'td', text: %r{#{ruleset.rules.first.rule}} }
      it { is_expected.not_to have_css 'tbody tr td:nth-of-type(3)' }
    end
  end
end
