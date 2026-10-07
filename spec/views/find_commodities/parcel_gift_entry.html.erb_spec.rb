require 'spec_helper'

RSpec.describe 'find_commodities/parcel_gift_entry', type: :view do
  let(:configured_journey) { Rails.configuration.parcel_gift_journey }
  let(:title) { 'Parcels, gifts, belongings' }
  let(:description) { configured_journey.homepage.description }
  let(:service_name) { 'uk' }
  let(:journey_path) { '/configured-parcel-gift-route' }
  let(:journey) { configured_journey }

  def journey_with(services:, description: configured_journey.homepage.description)
    raw = YAML.safe_load_file(Rails.root.join('config/parcel_gift_journey.yml'))
    raw.fetch('chooser')['services'] = services
    raw.fetch('homepage')['description'] = description
    TradeTariffFrontend::ParcelGiftJourney.new(raw, service_names: %w[uk xi])
  end

  def enable_journey
    allow(TradeTariffFrontend).to receive(:parcel_gift_journey_enabled?).and_return(true)
    allow(TradeTariffFrontend::ServiceChooser).to receive(:service_name).and_return(service_name)
    allow(Rails.configuration).to receive(:parcel_gift_journey).and_return(journey)
    path = journey_path
    route_name = journey.chooser.route_name
    view.define_singleton_method("#{route_name}_path") { path }
  end

  describe 'partial' do
    subject(:rendered_entry) { render partial: 'find_commodities/parcel_gift_entry' }

    context 'when the journey flag is off' do
      before do
        allow(TradeTariffFrontend).to receive(:parcel_gift_journey_enabled?).and_return(false)
      end

      it 'renders no entry' do
        expect(rendered_entry.strip).to eq('')
      end
    end

    context 'when the journey is enabled for the current service' do
      before { enable_journey }

      it 'renders the configured entry', :aggregate_failures do
        expect(configured_journey.homepage.title).to eq(title)
        expect(rendered_entry).to have_css('h2.govuk-heading-s a.govuk-link', text: title)
        expect(rendered_entry).to have_link(title, href: journey_path)
        expect(rendered_entry).to have_css('p.govuk-body', text: description)

        entry = Capybara.string(rendered_entry).find('#parcel-gift-entry')
        expect(entry[:class]).to include('app-card', 'app-parcel-gift-card')
        expect(entry).to have_css('svg[aria-hidden="true"][focusable="false"]')
        expect(entry).to have_css('a.app-parcel-gift-card__link.govuk-link--no-visited-state.govuk-link--no-underline', text: title)
        expect(entry).not_to have_css('.govuk-inset-text')
      end

      context 'with a different configured description' do
        let(:description) { 'A different configured parcel journey description.' }
        let(:journey) { journey_with(services: %w[uk], description:) }

        it 'renders that description' do
          expect(rendered_entry).to have_css('p.govuk-body', text: description)
        end
      end
    end

    context 'when the journey is enabled but the service is excluded' do
      let(:journey) { journey_with(services: %w[xi]) }

      before { enable_journey }

      it 'renders no entry' do
        expect(rendered_entry.strip).to eq('')
      end
    end

    context 'when the current service is xi and the configuration includes xi' do
      let(:service_name) { 'xi' }

      before { enable_journey }

      it 'renders the entry' do
        expect(rendered_entry).to have_link(title, href: journey_path)
      end
    end
  end

  describe 'find commodity pages' do
    let(:search) { build(:search, :with_search_date, q: '0101300000', search_date: Time.zone.today) }

    before do
      assign :search, search
      assign :recent_stories, build_list(:news_item, 3)
      allow(TradeTariffFrontend).to receive(:parcel_gift_journey_enabled?).and_return(false)
    end

    shared_examples 'an unchanged find commodity page' do |template|
      it 'keeps search and news', :aggregate_failures do
        rendered_page = render template: template

        expect(rendered_page).to have_css('h2', text: 'Search for a commodity')
        expect(rendered_page).to have_css('#recent-news h2', text: 'Latest news')
        expect(rendered_page).to have_css('.app-find-commodity-layout')
        expect(rendered_page).not_to have_css('#parcel-gift-entry')
        expect(rendered_page).not_to have_text(title)
      end
    end

    shared_examples 'a find commodity page with the parcel sidebar card' do |template|
      it 'puts one card first in the sidebar and preserves search', :aggregate_failures do
        enable_journey
        rendered_page = render template: template

        expect(rendered_page).to have_css('h2', text: 'Search for a commodity')
        expect(rendered_page).to have_css('#recent-news h2', text: 'Latest news')
        expect(rendered_page).to have_css('#parcel-gift-entry', count: 1)
        expect(rendered_page).to have_css('.app-find-commodity-layout .govuk-grid-column-one-third > #parcel-gift-entry:first-child')
        expect(rendered_page).not_to have_css('.govuk-grid-column-two-thirds #parcel-gift-entry')
        expect(rendered_page).to have_link(title, href: journey_path)
        expect(rendered_page.index('Search for a commodity')).to be < rendered_page.index(title)
        expect(rendered_page.index(title)).to be < rendered_page.index('Latest news')
      end
    end

    it_behaves_like 'an unchanged find commodity page', 'find_commodities/show'
    it_behaves_like 'an unchanged find commodity page', 'find_commodities/show_revised'
    it_behaves_like 'an unchanged find commodity page', 'find_commodities/show_interactive'

    it_behaves_like 'a find commodity page with the parcel sidebar card', 'find_commodities/show'
    it_behaves_like 'a find commodity page with the parcel sidebar card', 'find_commodities/show_revised'
    it_behaves_like 'a find commodity page with the parcel sidebar card', 'find_commodities/show_interactive'
  end
end
