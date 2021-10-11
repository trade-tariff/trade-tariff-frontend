require 'spec_helper'

RSpec.describe 'rules_of_origin/_tab.html.erb', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'rules_of_origin/tab',
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

  let(:schemes) do
    build_list :rules_of_origin_scheme, 1, rules: rules_data, fta_intro: fta_intro
  end

  let(:fta_intro) { "## Free Trade Agreement\n\nDetails of agreement" }

  it 'includes the countries name in the title' do
    expect(rendered_page).to \
      have_css 'h2', text: 'Preferential rules of origin for trading with France'
  end

  it 'shows the flag' do
    expect(rendered_page).to have_css 'h2 .country-flag[src*="flags/fr"]'
  end

  it 'references the commodity code' do
    expect(rendered_page).to have_css 'h3', text: /for commodity 2203000100/
  end

  it 'includes links in the sidebar' do
    expect(rendered_page).to have_css '#rules-of-origin__related-content nav li'
  end

  it 'includes the bloc intro' do
    expect(rendered_page).to have_css '#rules-of-origin__intro--bloc-scheme'
  end

  context 'with UK service' do
    include_context 'with UK service'

    it 'references the country in the introductory text' do
      expect(rendered_page).to \
        have_css 'p', text: /originating in the UK or France/
    end
  end

  context 'with XI service' do
    include_context 'with XI service'

    it 'references the country in the introductory text' do
      expect(rendered_page).to \
        have_css 'p', text: /originating in the EU or France/
    end
  end

  context 'with matched rules of origin' do
    let(:first_rule) { schemes[0].rules[0] }

    it 'shows rules table' do
      expect(rendered_page).to have_css 'table.govuk-table'
    end

    it 'shows row per rule' do
      expect(rendered_page).to have_css 'tbody tr', count: 1
    end

    it 'show rule heading' do
      expect(rendered_page).to \
        have_css 'tbody tr td', text: first_rule.heading
    end

    it 'shows rule description' do
      expect(rendered_page).to \
        have_css 'tbody tr td', text: first_rule.description
    end

    it 'formats the rule detail markdown' do
      expect(rendered_page).to \
        have_css '.tariff-markdown ul li', text: 'From materials'
    end

    it 'formats the scheme fta_intro markdown' do
      expect(rendered_page).to \
        have_css '.rules-of-origin-fta .tariff-markdown h2',
                 text: 'Free Trade Agreement'
    end

    it 'includes the introductory_notes section' do
      expect(rendered_page).to have_css 'details .tariff-markdown p',
                                        text: /Details of introductory notes/
    end

    it 'includes the non-preferential bloc' do
      expect(rendered_page).to have_css '.rules-of-origin__non-preferential'
    end
  end

  context 'without matched rules' do
    let(:rules_data) { [] }

    it 'does not shows rules table' do
      expect(rendered_page).not_to have_css 'table.govuk-table'
    end

    it 'shows no matched rules message' do
      expect(rendered_page).to \
        have_css 'p', text: /no product-specific rules/
    end

    it 'excludes the introductory_notes section' do
      expect(rendered_page).not_to have_css 'details .tariff-markdown'
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

    it 'includes the non-preferential bloc' do
      expect(rendered_page).to have_css '.rules-of-origin__non-preferential'
    end
  end

  context 'with blank fta_intro field' do
    let(:fta_intro) { '' }

    it 'does not show details of fta field' do
      expect(rendered_page).not_to have_css '.rules-of-origin-fta'
    end
  end
end
