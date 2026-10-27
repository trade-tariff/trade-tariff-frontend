require 'spec_helper'

RSpec.describe 'What are you importing?', type: :request do
  let(:page) { Capybara.string(response.body) }

  before do
    allow(TradeTariffFrontend).to receive(:duty_calculator_homepage_card_enabled?).and_return(true)
  end

  describe 'GET /duty-calculator/what-are-you-importing' do
    before { get what_are_you_importing_path }

    it 'shows the AI-assisted search step', :aggregate_failures do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css('span.govuk-caption-xl', text: 'Calculate import costs')
      expect(page).to have_css('h1', text: 'What are you importing?')
      expect(page).to have_text('Describe the goods you are importing.')
      expect(page).to have_text('AI-assisted search')
      expect(page).to have_text('BETA')
      expect(page).to have_css('label', text: 'Describe the goods or enter a 10 digit commodity code')
      expect(page).to have_text('For example, 55" 4K Ultra HD OLED Smart TV or 8528 72 40 00')
      expect(page).to have_button('Continue')
      expect(page).to have_css("form[action='#{what_are_you_importing_search_path}'][data-controller='guided-search-validation queued-search']")
      expect(page).to have_css('form[data-queued-search-direct-exact-code-value="true"]')
      expect(page).to have_field('interactive_search', type: 'hidden', with: 'true')
      expect(page).to have_link('Back', href: homepage_import_details_path)
      expect(page).not_to have_link('Cancel')
    end

    it 'passes the saved import date to the queued search', :aggregate_failures do
      post homepage_import_details_path, params: {
        duty_calculator_steps_import_details: {
          'import_date(3i)' => '27',
          'import_date(2i)' => '3',
          'import_date(1i)' => '2027',
          country_of_origin: 'AR',
        },
      }

      get what_are_you_importing_path
      expect(page).to have_field('year', type: 'hidden', with: '2027')
      expect(page).to have_field('month', type: 'hidden', with: '3')
      expect(page).to have_field('day', type: 'hidden', with: '27')
    end
  end

  describe 'POST /duty-calculator/what-are-you-importing' do
    let(:params) { { duty_calculator_steps_what_are_you_importing: { search_term: } } }
    let(:search_term) { '8528 72 40 00' }

    it 'shows an error when no search term is entered', :aggregate_failures do
      post what_are_you_importing_path, params: params.deep_merge(
        duty_calculator_steps_what_are_you_importing: { search_term: '' },
      )

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('.govuk-error-summary', text: 'Enter a search term')
      expect(page).to have_css('.govuk-error-message', text: 'Error: Enter a search term')
    end

    it 'saves the search term and starts the AI-assisted search' do
      post what_are_you_importing_path, params: params

      expect(response).to redirect_to(perform_search_path(q: search_term, interactive_search: true, duty_calculator: true))
    end

    it 'uses the standard guided search handoff' do
      post what_are_you_importing_search_path, params: { q: search_term, interactive_search: true }

      expect(response).to redirect_to(perform_search_path(q: search_term, interactive_search: true, duty_calculator: true))
    end

    it 'passes the saved import date to the guided search' do
      post homepage_import_details_path, params: {
        duty_calculator_steps_import_details: {
          'import_date(3i)' => '27',
          'import_date(2i)' => '3',
          'import_date(1i)' => '2027',
          country_of_origin: 'AR',
        },
      }

      post what_are_you_importing_search_path, params: { q: search_term, interactive_search: true }

      expect(response).to redirect_to(
        perform_search_path(q: search_term, interactive_search: true, duty_calculator: true, day: 27, month: 3, year: 2027),
      )
    end

    it 'uses the standard guided search validation', :aggregate_failures do
      post what_are_you_importing_search_path, params: { q: 'a', interactive_search: true }

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('.govuk-error-summary', text: 'Search term must be at least 2 characters')
    end
  end
end
