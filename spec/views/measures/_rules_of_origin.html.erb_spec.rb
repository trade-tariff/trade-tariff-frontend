require 'spec_helper'

describe 'measures/_rules_of_origin.html.erb', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'measures/rules_of_origin',
           country_code: 'FR',
           country_name: 'France',
           rules: rules
  end

  let(:rules) { [] }

  it 'includes the countries name in the title' do
    expect(rendered_page).to \
      have_css 'h2', text: 'Rules of origin for trading with France'
  end

  it 'shows the flag' do
    expect(rendered_page).to have_css 'h2 span.country-flag', text: '🇫🇷'
  end
end
