require 'spec_helper'

RSpec.describe 'Search analytics in the browser', :js, type: :feature do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  def journey_event(outcome)
    page.evaluate_async_script(<<~JS, outcome)
      const outcome = arguments[0];
      const done = arguments[1];
      const deadline = Date.now() + 4000;
      function check() {
        const event = window.dataLayer?.find(item => item.event === 'ott_search_journey' && item.outcome === outcome);
        if (event || Date.now() >= deadline) done(event || null);
        else setTimeout(check, 20);
      }
      check();
    JS
  end

  def accept_usage_cookies
    visit find_commodity_path
    click_button 'Accept additional cookies', visible: true
    visit find_commodity_path
  end

  let(:commodity) do
    {
      id: '123',
      type: 'commodity',
      attributes: {
        goods_nomenclature_item_id: '0101210000',
        goods_nomenclature_class: 'Commodity',
        description: 'Horses',
        classification_description: 'Horses',
        self_text: 'Horses',
        declarable: true,
        confidence: 'strong',
        score: 12.5,
      },
    }
  end

  it 'tracks guided questions and rendered results' do
    enable_feature(:interactive_search)
    question = { question: 'What type of horse?', options: %w[Racing Breeding], answer: nil }
    stub_api_request('search', :post, internal: true).to_return(
      {
        body: { data: [commodity], meta: { interactive_search: { request_id: 'browser-request', answers: [question] } } }.to_json,
        headers: { 'content-type' => 'application/json' },
      },
      {
        body: { data: [commodity], meta: { interactive_search: { request_id: 'browser-request', answers: [question.merge(answer: 'Racing')] } } }.to_json,
        headers: { 'content-type' => 'application/json' },
      },
    )
    accept_usage_cookies

    choose 'Guided search'
    fill_in 'Describe the products you are trading', with: 'horses'
    click_button 'Search for a commodity'

    expect(page).to have_content('What type of horse?')
    expect(journey_event('page_visible')).to include(
      'search_experience' => 'guided_beta', 'search_mode' => 'guided',
      'destination' => 'question', 'question_count' => 1, 'option_count' => 2
    )

    choose 'Racing'
    click_button 'Submit'

    expect(page).to have_link('View this commodity code', count: 1)
    event = journey_event('page_visible')
    expect(event).to include(
      'search_state' => 'results', 'destination' => 'results', 'result_count' => 1,
      'request_id' => 'browser-request', 'feature_flag_source' => 'flagsmith'
    )
    expect(event['client_navigation_ms']).to be_a(Numeric)
    expect(event.to_json).not_to match(/horses|Racing|Breeding|What type/)
    expect(page).to have_current_path('/search', ignore_query: true)
    expect(Rack::Utils.parse_query(URI.parse(page.current_url).query).keys).to match_array(%w[day month year])
  end

  it 'tracks classic results without adding URL parameters' do
    disable_feature(:interactive_search)
    stub_api_request('search', :post).to_return(jsonapi_response(:search, attributes_for(:search_outcome, :fuzzy_match)))
    accept_usage_cookies

    fill_in 'search-q-field', with: 'toothbrush'
    click_button 'Search for a commodity'

    expect(page).to have_css('h1', text: 'Search results')
    expect(journey_event('page_visible')).to include(
      'search_experience' => 'classic', 'search_mode' => 'keyword', 'destination' => 'results',
    )
    expect(page).to have_current_path('/search')
  end
end
