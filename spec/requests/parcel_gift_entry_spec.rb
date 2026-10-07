require 'spec_helper'

RSpec.describe 'Parcel journey homepage entry', type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  let(:journey) { Rails.configuration.parcel_gift_journey }
  let(:page) { Capybara.string(response.body) }

  %w[uk xi].each do |service|
    [true, false].each do |search_enabled|
      context "with #{service} and search flag #{search_enabled}" do
        before { TEST_FLAGSMITH_CLIENT.set_flag(:interactive_search, search_enabled) }

        it 'leaves the entry hidden by default', :aggregate_failures do
          disable_feature(:parcel_gift_journey)
          get "/#{service}/find_commodity"
          expect(response).to have_http_status(:ok)
          expect(page).not_to have_link(journey.homepage.title)
          expect(page).not_to have_css('#parcel-gift-entry')
          expect(page).not_to have_css('#find-commodity-date')
          expect(page).not_to have_css('.app-find-commodity-tools')
        end

        it 'offers the opt-in guidance route', :aggregate_failures do
          enable_feature(:parcel_gift_journey)
          get "/#{service}/find_commodity"
          expect(response).to have_http_status(:ok)
          expect(page).to have_link(journey.homepage.title, href: service == 'xi' ? '/xi/parcels-and-gifts' : '/parcels-and-gifts')
          expect(page).to have_css('.govuk-grid-column-one-third > #parcel-gift-entry:first-child', text: journey.homepage.description)
          expect(page).to have_css('#parcel-gift-entry', count: 1)
          expect(page).not_to have_css('.govuk-grid-column-two-thirds #parcel-gift-entry')
          expect(page).to have_css('#new_search button', text: 'Search for a commodity')
          expect(page).to have_css('.govuk-grid-column-two-thirds #recent-news.app-find-commodity-news')
          expect(page).to have_css('.app-find-commodity-search + #find-commodity-sidebar + .app-find-commodity-news-column')
          expect(page.all('#find-commodity-sidebar h2').map { |heading| heading.text(normalize_ws: true) }).to eq([journey.homepage.title, 'Using the tariff', 'Tools'])
          expect(page).to have_css('#recent-news', count: 1)
          expect(page).to have_css('details#find-commodity-date:not([open]) summary', text: 'Change date')
          expect(page).to have_css('#find-commodity-date legend', text: 'Change trade date', visible: :all)
          if service == 'xi' || !search_enabled
            expect(page).to have_css('#keyword-search-panel h2', text: 'Search for a commodity', exact_text: true)
            expect(page).to have_css('#keyword-search-panel summary', text: 'Tips on searching for products')
            expect(page).not_to have_css('[role="tablist"], #ai-search-panel, #revised-keyword-hint', visible: :all)
          end
          if service == 'xi'
            expect(page).to have_css('h1', text: 'Find commodity codes, import duties, taxes and controls')
            expect(page).to have_text('Tariff for Northern Ireland (NI)')
            expect(page).to have_css('.switch-service-control a[href="/find_commodity"]')
            expect(page).to have_css('label', text: 'Search the Northern Ireland Online Tariff')
            expect(page).to have_css('#new_search[action="/xi/search"]')
            expect(page).to have_css('.latest-news-banner', count: 1)
            expect(page).not_to have_css('#find-commodity-ni-guidance', visible: :all)
            expect(page).to have_link('Meursing code lookup', href: '/xi/meursing_lookup/steps/start')
            expect(page).not_to have_css('.app-find-commodity-tools a', text: 'Quotas')
          end
        end
      end
    end
  end

  it 'reopens invalid date fields on the XI keyword-only layout', :aggregate_failures do
    enable_feature(:parcel_gift_journey)
    get '/xi/find_commodity', params: { invalid_date: true, day: '22', month: '0', year: '2026' }

    expect(response).to have_http_status(:ok)
    expect(page).to have_css('details#find-commodity-date[open]')
    expect(page).to have_css('.govuk-error-summary', text: 'You must enter a valid date')
    expect(page).to have_css('#find-commodity-date input[name="search[as_of(2i)]"][value="0"]')
  end

  describe 'the opt-in UK homepage layout' do
    before do
      enable_feature(:parcel_gift_journey)
      enable_feature(:interactive_search)
    end

    it 'keeps news separate from search and tools in the sidebar', :aggregate_failures do
      get '/find_commodity'

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('.govuk-grid-column-two-thirds #recent-news.app-find-commodity-news')
      expect(page).to have_css('#find-commodity-sidebar h2', text: 'Tools')
      expect(page).not_to have_css('#find-commodity-sidebar h2', text: 'Latest news')
      expect(page).to have_link('Exchange rates', href: exchange_rates_path)
      expect(page).to have_link('Quotas', href: quota_search_path)
      expect(page).to have_link('Developer Portal (opens in new tab)', href: TradeTariffFrontend.developer_portal_url)
      expect(page).to have_css('.app-find-commodity-tools a[target="_blank"][rel="noopener noreferrer"]', text: 'Developer Portal (opens in new tab)')
      expect(page).to have_link('View all tariff tools', href: tools_path)
      expect(page).to have_css('.switch-service-control a[href="/xi/find_commodity"]')
    end

    it 'keeps keyword tips and moves AI help below submit', :aggregate_failures do
      get '/find_commodity'

      expect(page).not_to have_css('.app-ai-search-banner')
      expect(page).to have_css('#keyword-search-panel summary', text: 'Tips for using code or keyword search')
      expect(page).not_to have_css('#ai-search-panel summary', text: 'Tips for using AI-assisted search', visible: :all)
      keyword_panel = response.body[/id="keyword-search-panel".*?id="ai-search-panel"/m]
      expect(keyword_panel.index('Tips for using code or keyword search')).to be < keyword_panel.index('Search the UK Integrated Online Tariff')
      expect(page).to have_css('[data-search-mode-target="guidedHelp"] a[target="_blank"][rel="noopener noreferrer"]', text: 'AI-assisted search', visible: :all)
      expect(response.body.index('data-search-mode-target="guidedHelp"')).to be > response.body.index('type="submit"')
    end

    it 'collapses the default date fields while explaining the date used', :aggregate_failures do
      get '/find_commodity'

      expect(page).to have_css('details#find-commodity-date:not([open]) summary', text: 'Change date')
      expect(page).to have_text("Using today's date,")
      expect(page).to have_css('strong', text: Time.zone.today.strftime('%-d %B %Y'))
      expect(page).to have_css('#find-commodity-date input[name="search[as_of(3i)]"]', visible: :all)
    end

    it 'opens the date details and preserves invalid input on an error', :aggregate_failures do
      get '/find_commodity', params: { invalid_date: true, day: '22', month: '0', year: '2026' }

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('details#find-commodity-date[open]')
      expect(page).to have_css('.govuk-error-summary', text: 'You must enter a valid date')
      expect(page).to have_css('#find-commodity-date input[name="search[as_of(2i)]"][value="0"]')
      expect(page).not_to have_text("Using today's date,")
    end

    it 'hides the stated date and opens the fields when only some date parts arrive', :aggregate_failures do
      get '/find_commodity', params: { day: '22', month: '7' }

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('details#find-commodity-date[open]')
      expect(page).not_to have_css('[data-date-summary-target="summary"]')
      expect(page).not_to have_text("Using today's date,")
      expect(page).to have_css('#find-commodity-date input[name="search[as_of(3i)]"][value="22"]', visible: :all)
      expect(page).to have_css('#find-commodity-date input[name="search[as_of(2i)]"][value="7"]', visible: :all)
    end

    it 'shows a chosen date rather than claiming it uses today', :aggregate_failures do
      get '/find_commodity', params: { day: '22', month: '7', year: '2025' }

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('strong', text: '22 July 2025')
      expect(page).not_to have_text("Using today's date,")
    end

    it 'keeps keyword search without exposing AI when its independent flag is off', :aggregate_failures do
      disable_feature(:interactive_search)
      get '/find_commodity'

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('#keyword-search-panel')
      expect(page).not_to have_css('#ai-search-panel', visible: :all)
      expect(page).not_to have_css('[data-search-mode-target="guidedHelp"]', visible: :all)
      expect(page).to have_css('#find-commodity-date')
      expect(page).to have_css('#find-commodity-sidebar h2', text: 'Tools')
    end

    it 'preserves the original layout when the parcel flag is off', :aggregate_failures do
      disable_feature(:parcel_gift_journey)
      get '/find_commodity'

      expect(page).to have_css('.app-ai-search-banner')
      expect(page).to have_css('summary', text: 'Tips for using code or keyword search')
      expect(page).not_to have_css('#find-commodity-date')
      expect(page).to have_css('.govuk-grid-column-one-third #recent-news, .govuk-grid-column-one-third#recent-news')
      expect(page).not_to have_css('.app-find-commodity-tools')
      expect(page).to have_css('.switch-service-control')
    end
  end
end
