require 'spec_helper'

RSpec.describe 'rules_of_origin/_product_specific_rules', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'rules_of_origin/product_specific_rules',
           rule_sets:,
           commodity_code: '2203000100'
  end

  let(:rule_sets) { build_list :rules_of_origin_rule_set, 1 }

  it { is_expected.to have_css 'table' }
  it { is_expected.to have_css 'table th', count: 2 }
  it { is_expected.to have_css 'table td', count: 2 }
  it { is_expected.to have_css 'td', text: /#{rule_sets.first.rules.first.rule}/ }
  it { is_expected.to have_css 'td.tariff-markdown *' } # check markdown being rendered

  context 'with multiple rule sets' do
    let(:rule_sets) { build_list :rules_of_origin_rule_set, 3 }

    it { is_expected.to have_css 'table th', count: 3 }
    it { is_expected.to have_css 'table tr', count: 4 }
    it { is_expected.to have_css 'table td', count: 9 }
  end

  context 'with no rule sets' do
    let(:rule_sets) { [] }

    it { is_expected.to have_content 'no product-specific rules' }
    it { is_expected.not_to have_css 'table' }
  end
end
