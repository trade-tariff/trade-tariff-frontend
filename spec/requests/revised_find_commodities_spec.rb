require 'spec_helper'

RSpec.describe 'Revised find commodity page', :aggregate_failures, type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  before do
    allow(TradeTariffFrontend).to receive(:environment).and_return(environment)
    guided ? enable_feature(:interactive_search) : disable_feature(:interactive_search)
  end

  let(:environment) { 'production' }
  let(:guided) { false }

  def entry_page(params = {})
    get find_commodity_path, params: params
    expect(response).to have_http_status(:ok)
    Capybara.string(response.body)
  end

  %w[development staging production].each do |deployment|
    context "when deployed to #{deployment}" do
      let(:environment) { deployment }

      it 'keeps the existing page outside the AI cohort' do
        page = entry_page
        expect(page).to have_css('h1', text: 'Look up commodity codes, import duties, taxes and controls')
        expect(page).not_to have_link('AI-assisted search')
      end

      context 'with AI search enabled' do
        let(:guided) { true }

        it 'offers the two search modes' do
          page = entry_page
          expect(page).to have_link('Switch to the Northern Ireland Online Tariff')
          expect(page).to have_link('Keyword search')
          expect(page).to have_link('AI-assisted search')
          expect(page).not_to have_text('What type of search are you doing?')
          expect(page).not_to have_text('Importing goods into Northern Ireland?')
        end

        it 'ignores a remembered AI preference' do
          cookies[:interactive_search] = 'true'
          page = entry_page
          expect(page).to have_css('[data-search-mode-initial-mode-value="keyword"]')
        end

        it 'retains AI mode for invalid dates' do
          page = entry_page(interactive_search: 'true', q: 'coffee', invalid_date: true, day: '22', month: '0', year: '2026')
          expect(page).to have_css('[data-search-mode-initial-mode-value="guided"]')
          expect(page).to have_text('You must enter a valid date')
          expect(page).to have_field('Describe the products you are trading', with: 'coffee', disabled: true)
        end
      end
    end
  end

  context 'with AI validation errors' do
    let(:guided) { true }

    it 'retains AI mode and description after an invalid-date submission' do
      post perform_search_path, params: { interactive_search: 'true', search: { q: 'coffee beans', 'as_of(3i)' => '22', 'as_of(2i)' => '0', 'as_of(1i)' => '2026' } }
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-search-mode-initial-mode-value="guided"')
      expect(Capybara.string(response.body)).to have_field('Describe the products you are trading', with: 'coffee beans', disabled: true)
      expect(response.body).to include('You must enter a valid date')
    end

    it 'retains keyword text after an invalid-date submission' do
      post perform_search_path, params: { interactive_search: 'false', q: 'coffee beans', search: { 'as_of(3i)' => '22', 'as_of(2i)' => '0', 'as_of(1i)' => '2026' } }
      follow_redirect!

      expect(Capybara.string(response.body)).to have_field('revised-keyword-query', with: 'coffee beans')
      expect(response.body).to include('You must enter a valid date')
    end

    it 'returns to the revised AI panel' do
      post perform_search_path, params: { interactive_search: 'true', q: 'a' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-search-mode-initial-mode-value="guided"')
      expect(response.body).to include('Search term must be at least 2 characters')
      expect(Capybara.string(response.body)).to have_css('.switch-service-control', count: 1)
      expect(Capybara.string(response.body)).to have_link('Switch to the Northern Ireland Online Tariff', href: '/xi/find_commodity')
    end
  end

  context 'with analytics consent' do
    let(:guided) { true }

    it 'reports the actual initial mode' do
      cookies[:cookies_policy] = { usage: true }.to_json
      cookies[:interactive_search] = 'true'
      entry_page

      analytics = JSON.parse(Nokogiri::HTML(response.body).at_css('#search-analytics-context').text)
      expect(analytics).to include('search_mode' => 'keyword', 'search_experience' => 'guided_beta')
    end
  end

  context 'when on the XI service' do
    let(:guided) { true }

    it 'keeps the existing page' do
      get '/xi/find_commodity'
      expect(response.body).not_to include('data-controller="search-mode')
      expect(response.body).to include('Look up commodity codes, import duties, taxes and controls')
    end
  end
end
