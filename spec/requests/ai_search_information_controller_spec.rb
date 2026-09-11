require 'spec_helper'

RSpec.describe 'AI-assisted search information', type: :request do
  subject(:page) { Capybara.string(response.body) }

  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  let(:environment) { 'production' }
  let(:path) { '/news/service-updates/ai-assisted-search' }

  before do
    allow(TradeTariffFrontend).to receive(:environment).and_return(environment)
    enable_feature(:interactive_search)
  end

  describe 'GET /news/service-updates/ai-assisted-search' do
    %w[development staging production].each do |deployed_environment|
      context "when eligible in #{deployed_environment}" do
        let(:environment) { deployed_environment }

        before { get path }

        it 'shows the beta information', :aggregate_failures do
          expect(response).to have_http_status(:ok)
          expect(page).to have_css('h1', text: 'AI-assisted search')
          expect(page).to have_link('Try AI-assisted search', href: find_commodity_path(anchor: 'ai-search-panel'))
          expect(page).to have_link('the UK Online Trade Tariff Terms and Conditions', href: terms_path, target: '_blank')
          expect(page).to have_link('use feedback to report them', href: feedback_path)
          expect(page).to have_css('h2', text: 'How assisted search uses AI')
          expect(page).to have_css('h2', text: 'Can I use AI-assisted search on other devices')
          expect(page).to have_css('h2', text: 'Service changes and availability')
          expect(page).to have_content('Access does not automatically transfer to another browser or device.')
        end
      end
    end

    it 'does not enrol via the return link', :aggregate_failures do
      get path
      return_url = page.find_link('Try AI-assisted search')[:href]
      reset!
      disable_feature(:interactive_search)
      get return_url
      destination = Capybara.string(response.body)

      expect(response).to have_http_status(:ok)
      expect(destination).to have_field('q', disabled: false)
      expect(destination).not_to have_css('[data-controller~="search-mode"]')
      expect(destination).not_to have_field('Describe the products you are trading')
      expect(session[:experiment_url_optins]).to be_blank
      expect(session[:flagsmith_optin_traits]).to be_blank
      expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to be_empty
      get path
      expect(response).to redirect_to(find_commodity_path)
    end

    it 'does not enable AI on XI via the link', :aggregate_failures do
      get path
      return_url = page.find_link('Try AI-assisted search')[:href]
      get "/xi#{return_url}"
      destination = Capybara.string(response.body)

      expect(response).to have_http_status(:ok)
      expect(destination).to have_field('q', disabled: false)
      expect(destination).not_to have_css('[data-controller~="search-mode"]')
      expect(destination).not_to have_field('Describe the products you are trading')
      expect(session[:experiment_url_optins]).to be_blank
      expect(session[:flagsmith_optin_traits]).to be_blank
      expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to be_empty
    end

    context 'when AI search is disabled' do
      before do
        disable_feature(:interactive_search)
        get path
      end

      it 'returns to find commodity' do
        expect(response).to redirect_to(find_commodity_path)
      end
    end

    context 'when using the XI service' do
      before { get "/xi#{path}" }

      it 'returns to the XI find commodity page' do
        expect(response).to redirect_to('/xi/find_commodity')
      end
    end
  end
end
