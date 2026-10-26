require 'spec_helper'

RSpec.describe 'EORI number searches', :aggregate_failures, type: :request do
  subject(:page) { Capybara.string(response.body) }

  let(:message) { 'The Online Trade Tariff does not recognise EORI numbers. Search using a commodity code or a description of your goods' }

  shared_examples 'an EORI number error' do |field_id|
    it 'shows the error and the GOV.UK guidance without searching' do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css('.govuk-error-summary', text: 'There is a problem')
      expect(page).to have_link(message, href: "##{field_id}")
      expect(page).to have_css('.govuk-error-message', text: message)
      expect(page).to have_css('.govuk-inset-text', text: 'You can check an EORI number on GOV.UK (opens in new tab).')
      expect(page).to have_css(
        '.govuk-inset-text a[href="https://www.gov.uk/check-eori-number"][target="_blank"][rel="noopener noreferrer"]',
        text: 'check an EORI number on GOV.UK (opens in new tab)',
      )
      expect(a_request(:any, /search/)).not_to have_been_made
    end
  end

  context 'with classic search' do
    before { post perform_search_path, params: { q: 'gb 123 456 789' } }

    it_behaves_like 'an EORI number error', 'search-q-field-error'

    it 'keeps the search term in the search box' do
      expect(page).to have_field('search-q-field-error', with: 'gb 123 456 789')
    end
  end

  context 'with hybrid search' do
    before do
      enable_feature(:hybrid_search)
      post perform_search_path, params: { q: 'GB123456789000' }
    end

    it_behaves_like 'an EORI number error', 'search-q-field-error'
  end

  context 'with the XI service' do
    before { post '/xi/search', params: { q: 'XI123456789000' } }

    it_behaves_like 'an EORI number error', 'search-q-field-error'
  end

  context 'with interactive search' do
    before do
      enable_feature(:interactive_search)
      post perform_search_path, params: { q: 'GB1234567890123', interactive_search: 'true' }
    end

    it_behaves_like 'an EORI number error', 'search-q-field-error'

    it 'keeps the search term in the AI search box' do
      expect(page).to have_field('search-q-field-error', with: 'GB1234567890123', disabled: :all)
    end
  end

  context 'with queued guided search' do
    before { enable_feature(:interactive_search) }

    it 'does not queue the search and asks the browser to submit the form' do
      post queue_guided_search_path, params: { q: 'GB123456789', interactive_search: 'true' }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to include('validation_failed' => true)
      expect(a_request(:any, /search/)).not_to have_been_made
    end
  end
end
