require 'spec_helper'

RSpec.describe 'rules_of_origin/_product_specific_rules_uk', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'rules_of_origin/product_specific_rules_uk',
           rules_of_origin_schemes:,
           commodity_code: '2203000100'
  end

  let(:rules_of_origin_schemes) { build_list(:rules_of_origin_scheme, 1, rule_set_count: 1) }
  let(:rule_sets) { rules_of_origin_schemes.first.rule_sets }

  it { is_expected.to have_css 'table' }

  it { is_expected.to have_css 'table th', count: 4 }
  it { is_expected.to have_css 'table td', count: 4 }
  it { is_expected.to have_css 'td', text: /#{rule_sets.first.rules.first.rule}/ }
  it { is_expected.to have_css 'td.tariff-markdown *' } # check markdown being rendered

  context 'with multiple rule sets' do
    let(:rules_of_origin_schemes) { build_list(:rules_of_origin_scheme, 1, rule_set_count: 3) }

    it { is_expected.to have_css 'table th', count: 4 }
    it { is_expected.to have_css 'table tr', count: 4 }
    it { is_expected.to have_css 'table td', count: 12 }
  end

  context 'with footnotes on the rules' do
    let(:rules_of_origin_schemes) { build_list :rules_of_origin_scheme, 1, :rules_with_footnotes }

    let(:rules) do
      rules_of_origin_schemes.flat_map { |scheme| scheme.rule_sets.flat_map(&:rules) }
    end

    it { is_expected.to have_css 'td details summary', text: rules.first.rule }
    it { is_expected.to have_css 'td details .govuk-details__text *' }
  end
end
