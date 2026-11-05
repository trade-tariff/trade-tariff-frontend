require 'spec_helper'

RSpec.describe 'Shared search', :aggregate_failures, type: :request do
  before do
    enable_feature(:interactive_search)
  end

  {
    '/sections/1' => 'sections#show',
    '/chapters/01' => 'chapters#show',
    '/headings/0101' => 'headings#show',
    '/subheadings/0101210000-10' => 'subheadings#show',
    '/a-z-index/a' => 'search_references#az_index',
  }.each do |path, cassette|
    it "offers both searches on #{path}" do
      VCR.use_cassette(cassette) { get path }

      expect(response).to have_http_status(:ok)
      page = Capybara.string(response.body)
      expect(page).to have_css('form#new_search.app-search', count: 1)
      expect(page).to have_link('Code or keyword search', href: '#keyword-search-panel')
      expect(page).to have_link('AI-assisted search', href: '#ai-search-panel')
      expect(page).to have_css('[data-guided-search-validation-loading-page]', count: 1)
    end
  end

  it 'submits the selected trade context' do
    allow(SearchReference).to receive(:all).and_return([])
    submitted_search = nil
    allow(GuidedSearch::QueuedSearch).to receive(:submit) do |search|
      submitted_search = search
      SecureRandom.uuid
    end
    get '/a-z-index/a', params: { country: 'AD', day: '12', month: '10', year: '2020' }
    form = Nokogiri::HTML(response.body).at_css('form#new_search')
    fields = form.css('input[type="hidden"]').to_h { |input| [input['name'], input['value']] }
    fields[form.at_css('#ai-search-panel input')['name']] = 'cotton shirt'
    fields['interactive_search'] = 'true'

    post form['data-queued-search-url-value'], params: Rack::Utils.parse_nested_query(fields.to_query)

    expect(response).to have_http_status(:accepted)
    expect(response.parsed_body['date']).to eq('year' => 2020, 'month' => 10, 'day' => 12)
    expect(submitted_search.country).to eq('AD')
  end
end
