require 'spec_helper'

RSpec.describe 'AI-assisted search information', type: :request do
  subject(:page) { Capybara.string(response.body) }

  let(:environment) { 'development' }
  let(:path) { '/news/service-updates/ai-assisted-search' }

  before do
    allow(TradeTariffFrontend).to receive(:environment).and_return(environment)
    enable_feature(:interactive_search)
  end

  describe 'GET /news/service-updates/ai-assisted-search' do
    %w[development staging].each do |deployed_environment|
      context "when eligible in #{deployed_environment}" do
        let(:environment) { deployed_environment }

        before { get path }

        it 'shows the beta information', :aggregate_failures do
          expect(response).to have_http_status(:ok)
          expect(page).to have_css('h1', text: 'AI-assisted search')
          expect(page).to have_link('the UK Online Trade Tariff Terms and Conditions', href: terms_path, target: '_blank')
          expect(page).to have_link('use feedback to report them', href: feedback_path)
          expect(page).to have_css('h2', text: 'How assisted search uses AI')
          expect(page).to have_css('h2', text: 'Can I use AI-assisted search on other devices')
          expect(page).to have_css('h2', text: 'Service changes and availability')
          expect(page).to have_content('Access does not automatically transfer to another browser or device.')
        end
      end
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

    context 'when deployed to production' do
      let(:environment) { 'production' }

      before { get path }

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
