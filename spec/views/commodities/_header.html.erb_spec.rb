RSpec.describe 'commodities/_header', type: :view do
  subject(:rendered_page) do
    render 'commodities/header', commodity_code: '6204430000'
    rendered
  end

  let(:show_search) { false }

  before do
    assign :show_commodity_search_link, show_search
    assign :search, build(:search, country: 'CN', day: '15', month: '10', year: '2026')
    allow(view).to receive(:uk_service_choice?).and_return(true)
  end

  it 'keeps the existing commodity actions', :aggregate_failures do
    expect(rendered_page).to have_css('button#copy_code', text: 'Copy commodity code')
    expect(rendered_page).to have_link('Create and manage your tariff updates', href: '/subscriptions')
    expect(rendered_page).not_to have_link('Search for another commodity')
  end

  context 'with the UK search panel enabled' do
    let(:show_search) { true }

    it 'preserves filters in the fallback link' do
      expect(rendered_page).to have_link(
        'Search for another commodity',
        href: find_commodity_path(country: 'CN', day: '15', month: '10', year: '2026'),
      )
    end

    it 'places search with the page actions' do
      expect(rendered_page).to have_css(
        '.commodity-actions > a.commodity-action-button#commodity-search-toggle[data-commodity-search-target="trigger"][data-action="click->commodity-search#toggle"][aria-controls="commodity-search-panel"]',
        text: 'Search for another commodity',
      )
    end
  end

  context 'with the Northern Ireland service' do
    before { allow(view).to receive(:uk_service_choice?).and_return(false) }

    it 'keeps only the copy action', :aggregate_failures do
      expect(rendered_page).to have_css('button#copy_code')
      expect(rendered_page).not_to have_link('Create and manage your tariff updates')
      expect(rendered_page).not_to have_link('Search for another commodity')
    end
  end
end
