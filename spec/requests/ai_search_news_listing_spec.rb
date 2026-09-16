require 'spec_helper'

RSpec.describe 'AI-assisted search news listing', :aggregate_failures, type: :request do
  subject(:page) { Capybara.string(response.body) }

  let(:environment) { 'production' }
  let(:service_updates) { build(:news_collection, name: 'Service updates', slug: 'service_updates') }
  let(:other_collection) { build(:news_collection, name: 'Tariff notices', slug: 'tariff_notices') }
  let(:news_item) { build(:news_item, title: 'Latest tariff update', start_date: Date.new(2026, 7, 24)) }
  let(:paginated) { Kaminari.paginate_array([news_item], total_count: 1).page(1).per(10) }

  before do
    allow(TradeTariffFrontend).to receive_messages(environment:, basic_session_authentication?: false)
    allow(News::Year).to receive(:all).and_return([])
    allow(News::Collection).to receive(:all).and_return([service_updates, other_collection])
    allow(News::Item).to receive(:updates_page).and_return(paginated)
    enable_feature(:interactive_search)
  end

  it 'lists the beta update in date order on the news bulletin' do
    get news_items_path

    expect(page.all('article.news-item h2 a').map(&:text)).to eq(
      ['AI-assisted search', 'Latest tariff update'],
    )
    expect(page).to have_css('article.news-item h2 a[href="/news/service-updates/ai-assisted-search"]', text: 'AI-assisted search')
    expect(page).to have_content('Assisted search is currently in beta phase')
  end

  it 'lists the beta update on the service updates collection' do
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

  it 'lists the beta update when filtering by 2026' do
    get news_year_path(2026)

    expect(page).to have_link('AI-assisted search', href: ai_search_information_path)
  end

  it 'hides the beta update when filtering by another year' do
    get news_year_path(2025)

    expect(page).not_to have_link('AI-assisted search', href: ai_search_information_path)
  end

  it 'hides the beta update among newer later-page items' do
    allow(News::Item).to receive(:updates_page).and_return(
      Kaminari.paginate_array(
        [build(:news_item, title: 'Newer update', start_date: Date.new(2026, 9, 16))],
        total_count: 30,
      ).page(1).per(10),
    )

    get news_items_path(page: 2)

    expect(page).not_to have_link('AI-assisted search', href: ai_search_information_path)
  end

  it 'lists the beta update on the first older page' do
    newer_page = Kaminari.paginate_array(
      [build(:news_item, title: 'Newer update', start_date: Date.new(2026, 9, 16))],
      total_count: 20,
    ).page(1).per(10)
    older_page = Kaminari.paginate_array(
      [build(:news_item, title: 'Older update', start_date: Date.new(2026, 9, 8))],
      total_count: 20,
    ).page(1).per(10)

    allow(News::Item).to receive(:updates_page) do |**kwargs|
      kwargs[:page].to_i == 2 ? older_page : newer_page
    end

    get news_items_path(page: 2)

    expect(page).to have_link('AI-assisted search', href: ai_search_information_path)
    expect(News::Item).to have_received(:updates_page).with(hash_including(page: 1))
  end

  it 'hides the beta update on the XI service' do
    get '/xi/news'

    expect(page).not_to have_link('AI-assisted search')
  end
end
