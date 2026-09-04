require 'spec_helper'

RSpec.describe 'Guided search failure suggestions', type: :request do
  before { enable_feature(:interactive_search) }

  let(:commodity_data) do
    {
      'id' => '0101210000',
      'type' => 'commodity',
      'attributes' => {
        'goods_nomenclature_item_id' => '0101210000',
        'producline_suffix' => GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
        'goods_nomenclature_class' => 'Commodity',
        'description' => 'Pure-bred breeding animals',
        'formatted_description' => 'Pure-bred breeding animals',
        'declarable' => true,
        'score' => 12.5,
        'confidence' => 'strong',
      },
    }
  end

  it 'does not show the issue banner while asking questions', :aggregate_failures do
    stub_search_response(
      failures: %w[query_expansion_failed],
      answers: [pending_answer],
    )

    post perform_search_path, params: { q: 'horses', interactive_search: 'true' }

    page = Capybara.string(response.body)
    expect(page).not_to have_css('.govuk-notification-banner')
    expect(page).not_to have_text('Issues with AI-assisted search')
    expect(page).not_to have_text('These results are based on the words you entered.')
    expect(page).not_to have_css('[role="alert"]')
  end

  it 'shows the issue banner when the final results response is degraded', :aggregate_failures do
    stub_search_response(failures: %w[embedding_generation_failed], answers: [completed_answer])

    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'guided-request-123',
    }

    page = Capybara.string(response.body)
    expect(page).to have_css('.govuk-notification-banner', text: 'Issues with AI-assisted search')
    expect(page).to have_text('We are aware of some issues affecting AI-assisted search')
    expect(page).not_to have_text('These results use keyword matching.')
  end

  it 'retains a suggestion for the same request until the final results page', :aggregate_failures do
    stub_api_request('search', :post, internal: true).to_return(
      search_response(failures: %w[query_expansion_failed], answers: [pending_answer]),
      search_response(failures: [], answers: [completed_answer]),
    )

    post perform_search_path, params: { q: 'horses', interactive_search: 'true' }
    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'guided-request-123',
      current_question: 'What type of horse?',
      current_options: %w[Racing Breeding].to_json,
      interactive_search_form: { answer: '' },
    }

    expect(Capybara.string(response.body)).not_to have_text('Issues with AI-assisted search')

    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'guided-request-123',
    }

    expect(Capybara.string(response.body)).to have_text('Issues with AI-assisted search')

    stub_search_response(failures: [], answers: [completed_answer])
    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'guided-request-123',
    }

    expect(Capybara.string(response.body)).not_to have_text('Issues with AI-assisted search')
  end

  it 'retains a failure when a JSON response has a pending question' do
    stub_api_request('search', :post, internal: true).to_return(
      search_response(failures: %w[query_expansion_failed], answers: [pending_answer]),
      search_response(failures: [], answers: [completed_answer]),
    )

    post perform_search_path(format: :json), params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'guided-request-123',
    }
    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'guided-request-123',
    }

    expect(Capybara.string(response.body)).to have_text('Issues with AI-assisted search')
  end

  it 'retains failures independently for concurrent journeys' do
    stub_api_request('search', :post, internal: true).to_return(
      search_response(failures: %w[query_expansion_failed], answers: [pending_answer], request_id: 'journey-a'),
      search_response(failures: %w[opensearch_failed], answers: [pending_answer], request_id: 'journey-b'),
      search_response(failures: [], answers: [completed_answer], request_id: 'journey-b'),
      search_response(failures: [], answers: [completed_answer], request_id: 'journey-a'),
    )

    %w[journey-a journey-b].each do |request_id|
      post perform_search_path, params: { q: 'horses', interactive_search: 'true', request_id: }
    end
    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'journey-b',
    }
    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'journey-a',
    }

    expect(Capybara.string(response.body)).to have_text('Issues with AI-assisted search')
  end

  it 'retains only the five most recent enabled failure journeys', :aggregate_failures do
    responses = (1..6).map do |number|
      search_response(
        failures: %w[opensearch_failed],
        answers: [pending_answer],
        request_id: "journey-#{number}",
      )
    end
    responses += (1..6).map do |number|
      search_response(failures: [], answers: [completed_answer], request_id: "journey-#{number}")
    end
    stub_api_request('search', :post, internal: true).to_return(*responses)

    (1..6).each do |number|
      post perform_search_path, params: { q: 'horses', interactive_search: 'true', request_id: "journey-#{number}" }
    end

    post perform_search_path, params: { q: 'horses', interactive_search: 'true', request_id: 'journey-1' }
    expect(Capybara.string(response.body)).not_to have_text('Issues with AI-assisted search')

    (2..6).each do |number|
      post perform_search_path, params: { q: 'horses', interactive_search: 'true', request_id: "journey-#{number}" }
      expect(Capybara.string(response.body)).to have_text('Issues with AI-assisted search')
    end
  end

  it 'uses one issue banner for multiple failures', :aggregate_failures do
    stub_search_response(
      failures: %w[embedding_generation_failed vector_retrieval_failed opensearch_failed],
      answers: [completed_answer],
    )

    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'guided-request-123',
    }

    page = Capybara.string(response.body)
    expect(page).to have_css('.govuk-notification-banner', count: 1)
    expect(page).to have_text('Issues with AI-assisted search', count: 1)
    expect(page).to have_text('We are aware of some issues affecting AI-assisted search', count: 1)
    expect(page).not_to have_text('These results use keyword matching.')
    expect(page).not_to have_text('These results are based on the meaning of your description.')
  end

  it 'ignores unknown codes and records a bounded warning', :aggregate_failures do
    allow(Rails.logger).to receive(:warn)
    stub_search_response(failures: %w[future_failure], answers: [completed_answer])

    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'guided-request-123',
    }

    expect(Capybara.string(response.body)).not_to have_css('.govuk-notification-banner')
    expect(Rails.logger).to have_received(:warn).with(
      { event: 'guided_search.unknown_failure_code', failure_code: 'future_failure' }.to_json,
    )
  end

  it 'does not show copy for a disabled failure' do
    configured_messages = Rails.application.config.search_failure_messages.deep_dup
    configured_messages['query_expansion_failed']['enabled'] = false
    allow(Rails.application.config).to receive(:search_failure_messages).and_return(configured_messages)
    stub_search_response(failures: %w[query_expansion_failed], answers: [completed_answer])

    post perform_search_path, params: {
      q: 'horses',
      interactive_search: 'true',
      request_id: 'guided-request-123',
    }

    expect(Capybara.string(response.body)).not_to have_css('.govuk-notification-banner')
  end

  it 'does not let disabled-only journeys evict an enabled failure' do
    configured_messages = Rails.application.config.search_failure_messages.deep_dup
    configured_messages['query_expansion_failed']['enabled'] = false
    allow(Rails.application.config).to receive(:search_failure_messages).and_return(configured_messages)
    responses = [
      search_response(failures: %w[opensearch_failed], answers: [pending_answer], request_id: 'enabled-journey'),
      *(1..5).map do |number|
        search_response(
          failures: %w[query_expansion_failed],
          answers: [pending_answer],
          request_id: "disabled-journey-#{number}",
        )
      end,
      search_response(failures: [], answers: [completed_answer], request_id: 'enabled-journey'),
    ]
    stub_api_request('search', :post, internal: true).to_return(*responses)

    post perform_search_path, params: { q: 'horses', interactive_search: 'true', request_id: 'enabled-journey' }
    (1..5).each do |number|
      post perform_search_path,
           params: { q: 'horses', interactive_search: 'true', request_id: "disabled-journey-#{number}" }
    end
    post perform_search_path, params: { q: 'horses', interactive_search: 'true', request_id: 'enabled-journey' }

    expect(Capybara.string(response.body)).to have_text('Issues with AI-assisted search')
  end

  def pending_answer
    { 'question' => 'What type of horse?', 'options' => %w[Racing Breeding], 'answer' => nil }
  end

  def completed_answer
    pending_answer.merge('answer' => 'Breeding')
  end

  def stub_search_response(failures:, answers:, request_id: 'guided-request-123')
    stub_api_request('search', :post, internal: true).to_return(
      search_response(failures:, answers:, request_id:),
    )
  end

  def search_response(failures:, answers:, request_id: 'guided-request-123')
    {
      status: 200,
      body: {
        'data' => [commodity_data],
        'meta' => {
          'search_failures' => failures,
          'interactive_search' => {
            'query' => 'horses',
            'request_id' => request_id,
            'answers' => answers,
          },
        },
      }.to_json,
      headers: { 'content-type' => 'application/json; charset=utf-8' },
    }
  end
end
