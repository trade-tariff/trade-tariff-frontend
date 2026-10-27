RSpec.describe 'Caching of heading and chapter pages for a date other than today', type: :request do
  let(:today) { Time.zone.today }
  let(:todays_date_params) { { day: today.day.to_s, month: today.month.to_s, year: today.year.to_s } }
  let(:another_date_params) { { day: '1', month: '1', year: '2020' } }
  let(:written_keys) { [] }
  let(:backend_find_headers) { [] }

  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))
    allow(GeographicalArea).to receive(:all).and_return([])
    allow(RulesOfOrigin::Scheme).to receive_messages(for_heading_and_country: [], all: [])
    allow(Rails).to receive(:cache).and_return(ActionController::Base.cache_store)
    [Heading, Chapter].each do |model|
      allow(model).to receive(:find).and_wrap_original do |original, *arguments|
        backend_find_headers << arguments.third
        original.call(*arguments)
      end
    end
  end

  around do |example|
    original_caching = ActionController::Base.perform_caching
    original_store = ActionController::Base.cache_store
    ActionController::Base.perform_caching = true
    ActionController::Base.cache_store = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    ActionController::Base.perform_caching = original_caching
    ActionController::Base.cache_store = original_store
  end

  def get_page(path, cassette, params)
    recorder = ->(*, payload) { written_keys << payload[:key].to_s }

    ActiveSupport::Notifications.subscribed(recorder, 'cache_write.active_support') do
      VCR.use_cassette(cassette, allow_playback_repeats: true) { get path, params: }
    end

    expect(response).to have_http_status(:ok)
  end

  describe 'a heading' do
    let(:path) { '/headings/0101' }
    let(:cassette) { 'headings#show' }

    it 'writes the page fragment and sends no cache header for today', :aggregate_failures do
      get_page(path, cassette, todays_date_params)

      expect(written_keys.grep(/headings#show/)).not_to be_empty
      expect(backend_find_headers).to all(eq({}))
    end

    it 'writes no page fragment and asks the HTTP cache not to store the response for another date', :aggregate_failures do
      get_page(path, cassette, another_date_params)

      expect(written_keys.grep(/headings#show/)).to be_empty
      expect(backend_find_headers).to all(include('Cache-Control' => 'no-store'))
    end
  end

  describe 'a chapter' do
    let(:path) { '/chapters/01' }
    let(:cassette) { 'chapters#show' }

    it 'sends no cache header for today' do
      get_page(path, cassette, todays_date_params)

      expect(backend_find_headers).to all(eq({}))
    end

    it 'asks the HTTP cache not to store the response for another date' do
      get_page(path, cassette, another_date_params)

      expect(backend_find_headers).to all(include('Cache-Control' => 'no-store'))
    end
  end
end
