require 'spec_helper'

RSpec.describe 'Search analytics', :aggregate_failures, type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  def analytics_context
    node = Nokogiri::HTML(response.body).at_css('#search-analytics-context')
    JSON.parse(node.text) if node
  end

  before do
    cookies['cookies_policy'] = { usage: true }.to_json
  end

  it 'exposes the resolved beta decision' do
    enable_feature(:interactive_search)

    get find_commodity_path

    expect(analytics_context).to include(
      'search_experience' => 'guided_beta',
      'feature_flag_name' => 'interactive_search',
      'feature_flag_enabled' => true,
      'feature_flag_source' => 'flagsmith',
      'feature_flag_fallback_reason' => nil,
      'search_state' => 'entry',
    )
    expect(response.body.index('search-analytics-context')).to be < response.body.index('gtm.start')
    expect(response.body).to include('window.dataLayer.push(')
  end

  it 'keeps non-search page context unpublished' do
    enable_feature(:interactive_search)

    get privacy_path

    expect(response).to have_http_status(:ok)
    expect(analytics_context).to include(
      'search_experience' => 'guided_beta',
      'feature_flag_source' => 'flagsmith',
      'search_state' => nil,
    )
    expect(response.body).to include('window.dataLayer = window.dataLayer || [];')
    expect(response.body).not_to include('window.dataLayer.push(')
  end

  it 'identifies deliberately classic search' do
    disable_feature(:interactive_search)

    get find_commodity_path

    expect(analytics_context).to include(
      'search_experience' => 'classic',
      'search_mode' => 'keyword',
      'feature_flag_enabled' => false,
      'feature_flag_source' => 'flagsmith',
    )
  end

  it 'distinguishes a default from control' do
    get find_commodity_path

    expect(analytics_context).to include(
      'search_experience' => 'classic',
      'feature_flag_enabled' => false,
      'feature_flag_source' => 'default',
      'feature_flag_fallback_reason' => 'missing_flag',
    )
  end

  it 'identifies unavailable evaluation' do
    allow(FlagsmithClient.instance).to receive(:get_flags_for).and_raise(Faraday::ConnectionFailed, 'offline')

    get find_commodity_path

    expect(analytics_context).to include(
      'feature_flag_source' => 'default',
      'feature_flag_fallback_reason' => 'unavailable',
    )
  end

  it 'keeps the decision that rendered the page' do
    enable_feature(:interactive_search)
    flags = TEST_FLAGSMITH_CLIENT.get_flags_for(nil)
    allow(flags).to receive(:get_flag).and_call_original
    allow(flags).to receive(:get_flag).with('webchat').and_raise(StandardError, 'unrelated flag failure')
    allow(FlagsmithClient.instance).to receive(:get_flags_for).and_return(flags)

    get find_commodity_path

    expect(Capybara.string(response.body)).to have_link('AI-assisted search')
    expect(analytics_context).to include(
      'search_experience' => 'guided_beta',
      'feature_flag_source' => 'flagsmith',
      'feature_flag_fallback_reason' => nil,
    )
  end

  it 'identifies the XI service restriction' do
    enable_feature(:interactive_search)

    get '/xi/find_commodity'

    expect(analytics_context).to include(
      'search_experience' => 'classic',
      'feature_flag_enabled' => false,
      'feature_flag_source' => 'default',
      'feature_flag_fallback_reason' => 'unsupported_service',
    )
  end

  it 'accepts legacy string consent' do
    cookies['cookies_policy'] = { usage: 'true' }.to_json

    get find_commodity_path

    expect(analytics_context).to include('event' => 'ott_search_context', 'search_state' => 'entry')
    expect(response.body).to include('gtm.start')
  end

  it 'does not render analytics without consent' do
    cookies.delete('cookies_policy')

    get find_commodity_path

    expect(analytics_context).to be_nil
    expect(response.body).not_to include('gtm.start')
  end

  [false, 'false', 1, {}, []].each do |usage|
    it "rejects non-consent usage value #{usage.inspect}" do
      cookies['cookies_policy'] = { usage: }.to_json

      get find_commodity_path

      expect(analytics_context).to be_nil
      expect(response.body).not_to include('gtm.start')
    end
  end

  context 'with guided search' do
    let(:results) { [] }
    let(:intercept) { nil }
    let(:answers) do
      [
        { question: 'Private question', options: ['Private option'], answer: 'Private answer' },
        { question: 'Next private question', options: %w[One Two], answer: nil },
      ]
    end

    before do
      enable_feature(:interactive_search)
      stub_api_request('search', :post, internal: true).to_return(
        body: {
          data: results,
          meta: {
            description_intercept: intercept,
            interactive_search: {
              query: 'horse',
              request_id: 'backend-request-123',
              expanded_query: 'Private expanded text',
              answers:,
            },
          },
        }.to_json,
        headers: { 'content-type' => 'application/json' },
      )
    end

    it 'exposes question metrics without text' do
      post perform_search_path, params: { q: 'horse', interactive_search: 'true', client_elapsed_ms: '1234' }

      expect(analytics_context).to include(
        'search_mode' => 'guided', 'search_state' => 'question',
        'request_id' => 'backend-request-123', 'question_count' => 2,
        'option_count' => 2, 'result_count' => 0, 'client_elapsed_ms' => 1234
      )
      expect(analytics_context.to_json).not_to match(/Private|private|horse/)
    end

    it 'labels invalid input explicitly' do
      post perform_search_path, params: { q: '', interactive_search: 'true' }

      expect(analytics_context).to include('search_mode' => 'guided', 'search_state' => 'input_error')
    end

    context 'without results or more questions' do
      let(:answers) { [] }

      it 'exposes an explicit no-results state' do
        post perform_search_path, params: { q: 'horse', interactive_search: 'true' }

        expect(analytics_context).to include('search_state' => 'no_results', 'result_count' => 0)
      end
    end

    context 'with final matches' do
      let(:answers) { [] }
      let(:confidence) { 'strong' }
      let(:score) { 12.5 }
      let(:results) do
        [{
          id: '123',
          type: 'commodity',
          attributes: {
            goods_nomenclature_item_id: '0101210000',
            goods_nomenclature_class: 'Commodity',
            description: 'Horses',
            declarable: true,
            confidence:,
            score:,
          },
        }]
      end

      it 'identifies results independently of URL' do
        post perform_search_path, params: { q: 'horse', interactive_search: 'true' }

        expect(response).to have_http_status(:ok)
        expect(analytics_context).to include('search_state' => 'results', 'result_count' => 1)
        expect(request.original_url).to eq('http://www.example.com/search')
      end

      context 'with unknown confidence' do
        let(:confidence) { 'unknown' }

        it 'distinguishes the unknown-results state' do
          post perform_search_path, params: { q: 'horse', interactive_search: 'true' }

          expect(analytics_context).to include('search_state' => 'unknown_results')
        end
      end

      context 'with an exact code match' do
        let(:score) { nil }

        it 'retains the chosen guided mode' do
          post perform_search_path, params: { q: '0101210000', interactive_search: 'true' }

          expect(analytics_context).to include('search_state' => 'results', 'search_mode' => 'guided')
        end
      end
    end

    context 'with blocking guidance' do
      let(:answers) { [] }
      let(:intercept) { { excluded: true, message_header: 'Guidance', message: 'Guidance text' } }

      it 'distinguishes guidance from results' do
        post perform_search_path, params: { q: 'horse', interactive_search: 'true', request_id: 'existing-request' }

        expect(analytics_context).to include('search_state' => 'blocking_guidance')
      end
    end
  end

  it 'reuses the trusted experiment label' do
    experiment = Rails.application.config.experiment_urls.fetch(:trusted_trader_guided_search)

    travel_to(Time.utc(2026, 7, 27, 12)) do
      get experiment.path
      get find_commodity_path, params: { experiment: 'spoofed' }
    end

    expect(analytics_context).to include('experiment' => 'trstd-trdr')
  end

  it 'keeps beta experience for keyword results' do
    enable_feature(:interactive_search)
    stub_api_request('search', :post).to_return(jsonapi_response(:search, {
      type: 'fuzzy_match',
      goods_nomenclature_match: { chapters: [], headings: [], commodities: [], sections: [] },
      reference_match: { chapters: [], headings: [], commodities: [], sections: [] },
    }))

    post perform_search_path, params: { q: 'horse', request_id: 'keyword-request' }

    expect(response).to have_http_status(:ok)
    expect(analytics_context).to include(
      'search_experience' => 'guided_beta', 'search_mode' => 'keyword',
      'search_state' => 'no_results', 'request_id' => 'keyword-request'
    )
  end
end
