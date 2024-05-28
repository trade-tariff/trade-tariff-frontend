require 'spec_helper'

RSpec.describe 'rules_of_origin/_preferential', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let(:render_page) do
    render partial: 'rules_of_origin/preferential', locals: {
      rules_of_origin_schemes:,
      country_name:,
      country_code:,
    }
  end

  let(:rules_of_origin_schemes) { [] }

  context 'with no country selected' do
    let(:country_name) { '' }
    let(:country_code) { '' }

    it { is_expected.to have_css 'h3', text: 'Preferential rules of origin' }
    it { is_expected.to have_css 'p', text: 'Products which meet all preferential rules of origin' }
  end

  context 'with country selected' do
    let(:country_name) { 'Mexico' }
    let(:country_code) { 'MX' }

    context 'with no scheme' do
      it { is_expected.to have_css 'h2', text: 'Trading with ' + country_name }
    end

    context 'with scheme' do
      let(:rule_sets) { attributes_for_list :rules_of_origin_rule_set, 1 }
      let(:rules_of_origin_schemes) { build_list(:rules_of_origin_scheme, 1, rule_sets:) }

      it { is_expected.to have_css 'h2', text: 'Preferential rules of origin for trading with' }
    end
  end
end
