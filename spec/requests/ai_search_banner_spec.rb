require 'spec_helper'

RSpec.describe 'AI-assisted search banner', :aggregate_failures, type: :request do
  include_context 'with news updates stubbed'

  let(:environment) { 'production' }
  let(:hero_story) { build(:news_item, title: 'Latest tariff update') }

  before do
    allow(TradeTariffFrontend).to receive(:environment).and_return(environment)
    allow(News::Item).to receive(:latest_for_home_page).and_return(hero_story)
    enable_feature(:interactive_search)
  end

  it 'replaces hero news with the beta introduction and a new-tab information link' do
    get find_commodity_path

    page = Capybara.string(response.body)
    expect(page).to have_css('h2', text: 'Introducing AI-assisted search')
    expect(page).to have_css('a[href="/news/service-updates/ai-assisted-search"][target="_blank"]', text: 'AI-assisted search')
    expect(page).not_to have_text(hero_story.title)
    expect(News::Item).not_to have_received(:latest_for_home_page)
  end

  it 'shows the introduction on an AI validation response' do
    post perform_search_path, params: { interactive_search: 'true', q: 'a' }

    expect(Capybara.string(response.body)).to have_css('h2', text: 'Introducing AI-assisted search')
  end

  it 'retains hero news when AI is disabled' do
    disable_feature(:interactive_search)
    get find_commodity_path

    page = Capybara.string(response.body)
    expect(page).to have_css('h2', text: hero_story.title)
    expect(page).not_to have_link('AI-assisted search', href: ai_search_information_path)
  end
end
