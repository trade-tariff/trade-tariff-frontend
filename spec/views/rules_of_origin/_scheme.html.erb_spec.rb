require 'spec_helper'

RSpec.describe 'rules_of_origin/_scheme', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'rules_of_origin/scheme', scheme:, commodity_code: '2203000100'
  end

  let(:scheme) { build :rules_of_origin_scheme }

  it { is_expected.to have_css 'table' }
  it { is_expected.to have_css 'table th', count: 2 }
  it { is_expected.to have_css 'table td', count: 2 }
  it { is_expected.to have_css 'h3', text: /#{scheme.title}/ }
  it { is_expected.to have_css 'td', text: /#{scheme.v2_rules.first.rule}/ }
  it { is_expected.to have_css 'td.tariff-markdown *' } # check markdown being rendered

  context 'with multiple rule sets' do
    let(:scheme) { build :rules_of_origin_scheme, rule_set_count: 3 }

    it { is_expected.to have_css 'table th', count: 3 }
    it { is_expected.to have_css 'table tr', count: 4 }
    it { is_expected.to have_css 'table td', count: 9 }
  end

  context 'with no rule sets' do
    let(:scheme) { build :rules_of_origin_scheme, rule_set_count: 0 }

    it { is_expected.to have_content 'no product-specific rules' }
    it { is_expected.not_to have_css 'table' }
  end
end
