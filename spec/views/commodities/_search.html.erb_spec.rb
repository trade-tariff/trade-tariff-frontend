RSpec.describe 'commodities/_search', type: :view do
  subject(:rendered_page) do
    render 'commodities/search'
    rendered
  end

  let(:search) { build(:search, country: 'CN', day: '15', month: '10', year: '2026') }

  before do
    assign :search, search
    assign :ai_search_enabled, true
    assign :search_mode, 'keyword'
    assign :search_mode_from_url, false
  end

  it 'starts hidden with a named close button', :aggregate_failures do
    expect(rendered_page).to have_css('section#commodity-search-panel[hidden][aria-labelledby="commodity-search-heading"][data-commodity-search-target="panel"]', visible: :all)
    expect(rendered_page).to have_css('h2#commodity-search-heading', text: 'Search for another commodity', visible: :all)
    expect(rendered_page).to have_css('button[type="button"][aria-label="Close search"][data-action="click->commodity-search#close"]', visible: :all)
  end

  it 'reuses both search modes', :aggregate_failures do
    expect(rendered_page).to have_css('#keyword-search-tab', text: 'Keyword search', visible: :all)
    expect(rendered_page).to have_css('#ai-search-tab', text: 'AI-assisted search', visible: :all)
    expect(rendered_page).to have_css('#ai-search-tab .govuk-tag', text: 'Beta', visible: :all)
    expect(rendered_page).to have_css('form[action="/search"][method="post"][data-controller="search-mode guided-search-validation queued-search"][data-queued-search-url-value="/search/queued"]', visible: :all)
    expect(rendered_page).to have_css('button[type="submit"]', exact_text: 'Search', visible: :all)
  end

  it 'uses compact labels and hints', :aggregate_failures do
    expect(rendered_page).to have_css('label[for="revised-keyword-query"]', text: 'Product name or commodity code', visible: :all)
    expect(rendered_page).to have_css('#revised-keyword-hint', text: 'For example, tomatoes or 1234 5678 90', visible: :all)
    expect(rendered_page).to have_css('label', text: 'Describe your goods', visible: :all)
    expect(rendered_page).to have_css('textarea[rows="2"][data-guided-search-validation-target="textarea"]', visible: :all)
    expect(rendered_page).not_to include('Commodity codes are internationally recognised reference numbers')
    expect(rendered_page).not_to have_css('details', visible: :all)
    expect(rendered_page).not_to have_css('#find-commodity-date', visible: :all)
  end

  it 'preserves filters without duplicate IDs', :aggregate_failures do
    { country: 'CN', day: '15', month: '10', year: '2026' }.each do |name, value|
      expect(rendered_page).to have_css("form input[type='hidden'][name='#{name}'][value='#{value}']:not([id])", visible: :all)
    end
  end

  context 'with an invalid AI description' do
    before do
      assign :search_mode, 'guided'
      search.errors.add(:q, 'Enter a search term')
    end

    it 'keeps errors linked to the input', :aggregate_failures do
      expect(rendered_page).to have_css('.govuk-error-summary a[href="#search-q-field-error"]', text: 'Enter a search term', visible: :all)
      expect(rendered_page).to have_css('label[for="search-q-field-error"]', text: 'Describe your goods', visible: :all)
      expect(rendered_page).to have_css('.govuk-error-message#search-q-error', text: 'Enter a search term', visible: :all)
    end
  end
end
