require 'spec_helper'

RSpec.describe 'AI-assisted search news listing', :aggregate_failures, type: :request do
  subject(:page) { Capybara.string(response.body) }

  let(:environment) { 'production' }
  let(:service_updates) { build(:news_collection, name: 'Service updates', slug: 'service_updates') }
  let(:other_collection) { build(:news_collection, name: 'Tariff notices', slug: 'tariff_notices') }
  let(:news_item) { build(:news_item, title: 'Latest tariff update') }
  let(:paginated) { Kaminari.paginate_array([news_item], total_count: 10).page(1).per(10) }

  before do
    allow(TradeTariffFrontend).to receive(:environment).and_return(environment)
    allow(News::Year).to receive(:all).and_return([])
    allow(News::Collection).to receive(:all).and_return([service_updates, other_collection])
    allow(News::Item).to receive(:updates_page).and_return(paginated)
    enable_feature(:interactive_search)
  end

  it 'pins the beta update on the news bulletin' do
    get news_items_path

    expect(page).to have_css('article.news-item h2 a[href="/news/service-updates/ai-assisted-search"]', text: 'AI-assisted search')
    expect(page).to have_css('article.news-item', text: /Service updates/)
    expect(page).to have_content('Assisted search is currently in beta phase')
  end

  it 'pins the beta update on the service updates collection' do
    get news_collection_path(service_updates)

    expect(page).to have_link('AI-assisted search', href: ai_search_information_path)
  end

  it 'hides the beta update when AI is disabled' do
    disable_feature(:interactive_search)
    get news_items_path

    expect(page).not_to have_link('AI-assisted search', href: ai_search_information_path)
  end

  it 'hides the beta update on other collections' do
    get news_collection_path(other_collection)

    expect(page).not_to have_link('AI-assisted search', href: ai_search_information_path)
  end

  it 'hides the beta update when filtering by year' do
    get news_year_path(2026)

    expect(page).not_to have_link('AI-assisted search', href: ai_search_information_path)
  end

  it 'hides the beta update on later pages' do
    get news_items_path(page: 2)

    expect(page).not_to have_link('AI-assisted search', href: ai_search_information_path)
  end

  it 'hides the beta update on the XI service' do
    get '/xi/news'

    expect(page).not_to have_link('AI-assisted search', href: '/xi/news/service-updates/ai-assisted-search')
  end
end
