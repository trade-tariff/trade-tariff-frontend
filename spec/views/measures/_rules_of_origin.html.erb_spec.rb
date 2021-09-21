require 'spec_helper'

describe 'measures/_rules_of_origin.html.erb', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'measures/rules_of_origin',
           country_code: 'FR',
           country_name: 'France',
           commodity_code: '2203000100',
           rules_of_origin: schemes
  end

  let :rules_data do
    attributes_for_list :rules_of_origin_rule,
                        1,
                        rule: "Manufacture\n\n* From materials"
  end

  let(:schemes) { build_list :rules_of_origin_scheme, 1, rules: rules_data }

  it 'includes the countries name in the title' do
    expect(rendered_page).to \
      have_css 'h2', text: 'Rules of origin for trading with France'
  end

  it 'shows the flag' do
    expect(rendered_page).to have_css 'h2 .country-flag[src*="flags/fr"]'
  end

  it 'references the commodity code' do
    expect(rendered_page).to have_css 'h3', text: /for commodity 2203000100/
  end

  context 'with UK service' do
    before do
      allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_return('uk')
    end

    it 'references the country in the introductory text' do
      expect(rendered_page).to \
        have_css 'p', text: /originating in the UK or France/
    end
  end

  context 'with XI service' do
    before do
      allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_return('xi')
    end

    it 'references the country in the introductory text' do
      expect(rendered_page).to \
        have_css 'p', text: /originating in the EU or France/
    end
  end

  context 'with matched rules' do
    let(:rules) { schemes.flat_map(&:rules) }

    it 'shows rules table' do
      expect(rendered_page).to have_css 'table.govuk-table'
    end

    it 'shows row per rule' do
      expect(rendered_page).to have_css 'tbody tr', count: 1
    end

    it 'show rule heading' do
      expect(rendered_page).to \
        have_css 'tbody tr td', text: rules[0].heading
    end

    it 'shows rule description' do
      expect(rendered_page).to \
        have_css 'tbody tr td', text: rules[0].description
    end

    it 'formats the rule detail markdown' do
      expect(rendered_page).to \
        have_css '.tariff-markdown ul li', text: 'From materials'
    end
  end

  context 'without matched rules' do
    let(:rules_data) { [] }

    it 'shows rules table' do
      expect(rendered_page).to have_css 'table.govuk-table'
    end

    it 'shows no matched rules message' do
      expect(rendered_page).to \
        have_css 'tbody td', text: /no product-specific rules/
    end
  end
end
