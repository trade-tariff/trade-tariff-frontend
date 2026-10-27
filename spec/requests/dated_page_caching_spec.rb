RSpec.describe 'Caching of pages for a date other than today', type: :request do
  let(:path) { '/commodities/0101300000' }
  let(:cassette) { 'commodities#0101300000#uk' }
  let(:today) { Time.zone.today }
  let(:todays_date_params) { { day: today.day.to_s, month: today.month.to_s, year: today.year.to_s } }
  let(:another_date_params) { { day: '1', month: '1', year: '2020' } }
  let(:written_keys) { [] }
  let(:backend_find_headers) { [] }

  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))
    allow(GeographicalArea).to receive(:all).and_return([])
    allow(RulesOfOrigin::Scheme).to receive_messages(for_heading_and_country: [], all: [])
    allow(DeclarableUnitService).to receive(:new).and_return(instance_double(DeclarableUnitService, call: 'No supplementary units'))
    allow(Rails).to receive(:cache).and_return(ActionController::Base.cache_store)
    allow(Commodity).to receive(:find).and_wrap_original do |original, *arguments|
      backend_find_headers << arguments.third
      original.call(*arguments)
    end
  end

  around do |example|
    original_caching = ActionController::Base.perform_caching
    original_store = ActionController::Base.cache_store
    store = ActiveSupport::Cache::MemoryStore.new
    ActionController::Base.perform_caching = true
    ActionController::Base.cache_store = store
    example.run
  ensure
    ActionController::Base.perform_caching = original_caching
    ActionController::Base.cache_store = original_store
  end

  def get_page(params)
    recorder = ->(*, payload) { written_keys << payload[:key].to_s }

    ActiveSupport::Notifications.subscribed(recorder, 'cache_write.active_support') do
      VCR.use_cassette(cassette, allow_playback_repeats: true) { get path, params: }
    end

    expect(response).to have_http_status(:ok)
  end

  def written_key_matching(text)
    written_keys.find { |key| key.include?(text) }
  end

  context 'when the request has no date' do
    before { get_page({}) }

    it 'caches the commodity object, the page fragment and the backend response', :aggregate_failures do
      expect(written_key_matching('commodities#uk_commodity')).to be_present
      expect(written_key_matching('commodities#show')).to be_present
      expect(backend_find_headers).to all(eq({}))
    end
  end

  context 'when the request gives today as the date' do
    before { get_page(todays_date_params) }

    it 'caches the commodity object, the page fragment and the backend response', :aggregate_failures do
      expect(written_key_matching('commodities#uk_commodity')).to be_present
      expect(written_key_matching('commodities#show')).to be_present
      expect(backend_find_headers).to all(eq({}))
    end
  end

  context 'when the request gives another date' do
    before { get_page(another_date_params) }

    it 'does not cache the commodity object or the page fragment', :aggregate_failures do
      expect(written_key_matching('commodities#uk_commodity')).to be_nil
      expect(written_key_matching('commodities#show')).to be_nil
    end

    it 'asks the HTTP cache not to store the backend response' do
      expect(backend_find_headers).to all(include('Cache-Control' => 'no-store'))
    end
  end
end
