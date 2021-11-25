require 'spec_helper'

RSpec.describe 'rules_of_origin/_rules_table.html.erb', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let(:country_name) { 'Kenya' }
  let(:scheme) { build :rules_of_origin_scheme }

  let :rules do
    build_list :rules_of_origin_rule, 3, rule: "Manufacture\n\n* From materials"
  end

  let :render_page do
    render 'rules_of_origin/rules_table', rules: rules,
                                          country_name: country_name
  end

  it 'shows rules table' do
    expect(rendered_page).to have_css 'table.govuk-table'
  end

  it 'shows row per rule' do
    expect(rendered_page).to have_css 'tbody tr', count: 3
  end

  it 'show rule heading' do
    expect(rendered_page).to \
      have_css 'tbody tr td', text: rules.first.heading
  end

  it 'shows rule description' do
    expect(rendered_page).to \
      have_css 'tbody tr td', text: rules.first.description
  end

  it 'formats the rule detail markdown' do
    expect(rendered_page).to \
      have_css '.tariff-markdown ul li', text: 'From materials'
  end

  context 'with UK service' do
    include_context 'with UK service'

    it 'references the country in the introductory text' do
      expect(rendered_page).to \
        have_css 'p', text: /originating in the UK or #{country_name}/
    end
  end

  context 'with XI service' do
    include_context 'with XI service'

    it 'references the country in the introductory text' do
      expect(rendered_page).to \
        have_css 'p', text: /originating in the EU or #{country_name}/
    end
  end
end
