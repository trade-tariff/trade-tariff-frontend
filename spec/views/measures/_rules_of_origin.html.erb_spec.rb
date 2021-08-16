require 'spec_helper'

describe 'measures/_rules_of_origin.html.erb', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'measures/rules_of_origin',
           country_code: 'FR',
           country_name: 'France',
           commodity_code: '2203000100',
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
end
