RSpec.describe 'HTTP cache for backend calls on dated pages', type: :request do
  let(:path) { '/commodities/0101300000' }
  let(:backend_commodity_request) { a_request(:get, %r{/uk/api/commodities/0101300000}) }
  let(:another_date) { Date.new(2020, 1, 1) }
  let(:another_date_params) { { day: '1', month: '1', year: '2020' } }
  let(:store) { ActiveSupport::Cache::MemoryStore.new }
  let(:store_writes) { [] }

  # The recorded response says "private", which a shared cache does not store.
  # The stub keeps the recorded body and says "public", as the backend does.
  let(:commodity_body) do
    cassette = YAML.safe_load_file(Rails.root.join('spec/vcr/commodities_0101300000_uk.yml'), permitted_classes: [Symbol])
    cassette['http_interactions'].first.dig('response', 'body', 'string')
  end

  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))
    allow(GeographicalArea).to receive(:all).and_return([])
    allow(RulesOfOrigin::Scheme).to receive_messages(for_heading_and_country: [], all: [])
    allow(DeclarableUnitService).to receive(:new).and_return(instance_double(DeclarableUnitService, call: 'No supplementary units'))

    stub_request(:get, %r{/uk/api/commodities/0101300000}).to_return(
      status: 200,
      body: commodity_body,
      headers: {
        'Content-Type' => 'application/json; charset=utf-8',
        'Cache-Control' => 'public, max-age=120',
        'ETag' => '"commodity-etag"',
      },
    )

    # The app builds its backend clients once, with the cache of that moment, so
    # the test gives the page a client with a cache it can look at.
    client = ClientBuilder.new('uk', cache: store).call
    allow(TradeTariffFrontend::ServiceChooser).to receive(:api_client).and_return(client)
  end

  def get_page(params = {})
    recorder = lambda do |*, payload|
      store_writes << payload[:key] if payload[:store] == store.class.name
    end

    ActiveSupport::Notifications.subscribed(recorder, 'cache_write.active_support') do
      get path, params:
    end

    expect(response).to have_http_status(:ok)
  end

  context 'when the page is for today' do
    it 'stores the backend response and reuses it', :aggregate_failures do
      get_page
      expect(store_writes).not_to be_empty

      get_page
      expect(backend_commodity_request).to have_been_made.once
    end
  end

  context 'when the page is for another date' do
    it 'does not store the backend response', :aggregate_failures do
      get_page(another_date_params)
      get_page(another_date_params)

      expect(store_writes).to be_empty
      expect(backend_commodity_request).to have_been_made.twice
    end

    it 'does not read an entry that is already in the cache', :aggregate_failures do
      # Same URL as the page request: the controller sends as_of and the Meursing filter.
      Commodity.find('0101300000', { as_of: another_date, filter: { meursing_additional_code_id: nil } })
      expect(backend_commodity_request).to have_been_made.once

      get_page(another_date_params)

      expect(store_writes).to be_empty
      expect(backend_commodity_request).to have_been_made.twice
    end
  end
end
