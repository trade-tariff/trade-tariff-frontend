require 'spec_helper'

RSpec.describe 'rules_of_origin/_tab', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'rules_of_origin/tab',
           country_code: 'FR',
           country_name: 'France',
           commodity_code: '2203000100',
           rules_of_origin_schemes: schemes,
           import_trade_summary: build(:import_trade_summary,
                                       preferential_tariff_duty:,
                                       preferential_quota_duty:)
  end

  let :rules_data do
    attributes_for_list :rules_of_origin_rule,
                        1,
                        rule: "Manufacture\n\n* From materials"
  end

  let(:schemes) do
    build_list :rules_of_origin_scheme, 1, rules: rules_data, fta_intro:
  end

  let(:fta_intro) { "## Free Trade Agreement\n\nDetails of agreement" }

  let(:preferential_tariff_duty) { nil }
  let(:preferential_quota_duty) { nil }

  it 'includes the countries name in the title' do
    expect(rendered_page).to \
      have_css 'h2', text: 'Preferential rules of origin for trading with France'
  end

  it 'shows the flag' do
    expect(rendered_page).to have_css 'h2 .country-flag[src*="flags/fr"]'
  end

  it 'includes links in the sidebar' do
    expect(rendered_page).to have_css '#rules-of-origin__related-content nav li'
  end

  it 'includes the bloc intro' do
    expect(rendered_page).to have_css '#rules-of-origin__intro--bloc-scheme'
  end

  context 'with matched rules of origin' do
    let(:first_rule) { schemes[0].rules[0] }

    it 'includes the non-preferential bloc' do
      expect(rendered_page).to have_css '.rules-of-origin__non-preferential'
    end
  end

  context 'without matched rules' do
    let(:rules_data) { [] }

    it 'does not shows rules table' do
      expect(rendered_page).not_to have_css 'table.govuk-table'
    end

    it 'includes the non-preferential bloc' do
      expect(rendered_page).to have_css '.rules-of-origin__non-preferential'
    end
  end

  context 'with country specific scheme' do
    let(:schemes) do
      build_list :rules_of_origin_scheme, 1, rules: rules_data, countries: %w[FR]
    end

    it { is_expected.to have_css '#rules-of-origin__intro--country-scheme' }
  end

  context 'with no scheme' do
    let(:schemes) { [] }

    it { is_expected.to have_css '#rules-of-origin__intro--no-scheme' }
    it { is_expected.not_to have_css '.rules-of-origin__scheme' }

    it 'includes the non-preferential bloc' do
      expect(rendered_page).to have_css '.rules-of-origin__non-preferential'
    end
  end

  context 'with multiple schemes' do
    let(:schemes) do
      build_list :rules_of_origin_scheme, 3, rules: rules_data,
                                             fta_intro:
    end

    it 'includes one non-preferential bloc' do
      expect(rendered_page).to have_css '.rules-of-origin__non-preferential', count: 1
    end
  end

  context 'with blank fta_intro field' do
    let(:fta_intro) { '' }

    it 'does not show details of fta field' do
      expect(rendered_page).not_to have_css '.rules-of-origin-fta'
    end
  end

  describe 'import trade summary duty box' do
    context 'when preferential tariff duty is present' do
      let(:preferential_tariff_duty) { '1.00 %' }

      it { expect(rendered_page).to have_css '.preferential-tariff-duty' }
    end

    context 'when preferential quota duty is present' do
      let(:preferential_quota_duty) { '1.00 %' }

      it { expect(rendered_page).to have_css '.preferential-quota-duty' }
    end

    context 'when both preferential duties are missing' do
      it { expect(rendered_page).not_to have_css '.preferential-tariff-duty' }
      it { expect(rendered_page).not_to have_css '.preferential-quota-duty' }

      it { expect(rendered_page).to have_css '.no-preferential-duties' }
    end
  end
end
