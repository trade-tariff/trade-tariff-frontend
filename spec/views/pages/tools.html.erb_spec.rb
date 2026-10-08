require 'spec_helper'

RSpec.describe 'pages/tools', type: :view do
  subject(:rendered_page) { render && rendered }

  context 'with UK service' do
    include_context 'with UK service'

    before do
      allow(TradeTariffFrontend).to receive(:developer_portal_url).and_return('https://hub.dev.trade-tariff.service.gov.uk/')
    end

    it 'renders tools as GOV.UK card links', :aggregate_failures do
      expect(rendered_page).to have_css('.gem-c-cards__list.gem-c-cards__list--one-column')
      expect(rendered_page).to have_css('.gem-c-cards__list-item', count: 9)
      expect(rendered_page).to have_css('.gem-c-cards__link', text: 'Exchange rates')
      expect(rendered_page).to have_link('Change to Northern Ireland tariff', href: '/xi/tools')
      expect(rendered_page).to have_link(
        'Simplified Process for Internal Market Movements (SPIMM) eligibility checker',
        href: '/check_simplified_processes_eligibility',
      )
    end

    it 'renders the reviewed tools content without trailing full stops', :aggregate_failures do
      expect(rendered_page).to have_css('.gem-c-cards__link', text: 'Exchange rates')
      expect(rendered_page).to have_css('.gem-c-cards__description', text: 'Use official exchange rates for customs values. View average monthly exchange rates, or download in CSV or XML')
      expect(rendered_page).to have_css('.gem-c-cards__link', text: 'Simplified procedure value rates')
      expect(rendered_page).to have_css('.gem-c-cards__description', text: 'Check simplified procedure value rates for fresh fruit and vegetables')
      expect(rendered_page).to have_css('.gem-c-cards__description', text: 'Search tariff quotas. Balances are updated daily')
      expect(rendered_page).to have_css('.gem-c-cards__description', text: 'Find document codes and guidance for importing and exporting goods')
      expect(rendered_page).to have_css('.gem-c-cards__description', text: 'Find additional codes for use on customs declarations')
      expect(rendered_page).to have_css('.gem-c-cards__description', text: 'Search footnotes applying to a commodity code')
      expect(rendered_page).to have_css('.gem-c-cards__description', text: 'Look up chemicals by CAS Registry Number (RN)')

      descriptions = Capybara.string(rendered_page).all('.gem-c-cards__description')
                                .map { |description| description.text.strip }
                                .reject { |description| description.start_with?('Check eligibility for the SPIMM') }
      expect(descriptions).not_to include(a_string_matching(/\.\z/))
    end

    it 'links to the Developer Portal in a new tab', :aggregate_failures do
      expect(rendered_page).to have_link(
        'Developer Portal (opens in new tab)',
        href: 'https://hub.dev.trade-tariff.service.gov.uk/',
      )
      expect(rendered_page).to have_css(
        'a#developer-portal-tools-link[target="_blank"][rel="noopener noreferrer"]',
        text: 'Developer Portal (opens in new tab)',
      )
      expect(rendered_page).to have_css(
        'a#developer-portal-tools-link[data-controller="analytics"][data-action="click->analytics#track"][data-analytics-event="developer_portal_tools_link_click"]',
      )
      expect(rendered_page).to have_css(
        '.gem-c-cards__description',
        text: 'Access official trade tariff data from HMRC and create and manage API keys',
      )
    end

    it 'does not render a status tag for the Developer Portal' do
      developer_portal_card = Capybara.string(rendered_page).find('.gem-c-cards__list-item', text: 'Developer Portal')

      expect(developer_portal_card).not_to have_css('.govuk-tag')
    end
  end

  context 'with XI service' do
    include_context 'with XI service'

    before do
      allow(TradeTariffFrontend).to receive(:developer_portal_url).and_return('https://hub.dev.trade-tariff.service.gov.uk/')
    end

    it 'renders existing XI tools as cards including the Developer Portal link', :aggregate_failures do
      expect(rendered_page).to have_css('.app-find-commodity-service', count: 1)
      expect(rendered_page).to have_css('.switch-service-control', count: 1)
      expect(rendered_page).to have_css('.gem-c-cards__list-item', count: 8)
      expect(rendered_page).to have_text('Tariff for Northern Ireland (NI)')
      expect(rendered_page).to have_link('Change to England, Scotland and Wales (GB) tariff', href: '/tools')
      expect(rendered_page).to have_link('Meursing code finder')
      expect(rendered_page).to have_link(
        'Developer Portal (opens in new tab)',
        href: 'https://hub.dev.trade-tariff.service.gov.uk/',
      )
      expect(rendered_page).to have_link(
        'Simplified Process for Internal Market Movements (SPIMM) eligibility checker',
        href: '/xi/check_simplified_processes_eligibility',
      )
      expect(rendered_page).to have_css(
        '.gem-c-cards__description',
        text: 'Check eligibility for the SPIMM when moving goods from Great Britain to Northern Ireland.',
      )

      descriptions = Capybara.string(rendered_page).all('.gem-c-cards__description')
                                .map { |description| description.text.strip }
                                .reject { |description| description.start_with?('Check eligibility for the SPIMM') }
      expect(descriptions).not_to include(a_string_matching(/\.\z/))
    end
  end
end
