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

  def get_page(params, status: :ok)
    recorder = ->(*, payload) { written_keys << payload[:key].to_s }

    ActiveSupport::Notifications.subscribed(recorder, 'cache_write.active_support') do
      VCR.use_cassette(cassette, allow_playback_repeats: true) { get path, params: }
    end

    expect(response).to have_http_status(status)
  end

  def record_backend_headers_for(model)
    allow(model).to receive(:find).and_wrap_original do |original, *arguments|
      backend_find_headers << arguments.third
      original.call(*arguments)
    end
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

  context 'with an XI commodity' do
    let(:path) { '/xi/commodities/0101300000' }
    let(:cassette) { 'commodities#0101300000#xi' }

    it 'caches both commodity objects and the page fragment, and sends no cache header on either backend call, for today', :aggregate_failures do
      get_page(todays_date_params)

      expect(written_key_matching('commodities#xi_commodity')).to be_present
      expect(written_key_matching('commodities#uk_commodity')).to be_present
      expect(written_key_matching('commodities#show')).to be_present
      expect(backend_find_headers).to eq([{}, {}])
    end

    it 'caches nothing and asks the HTTP cache not to store either response for another date', :aggregate_failures do
      get_page(another_date_params)

      expect(written_key_matching('commodities#xi_commodity')).to be_nil
      expect(written_key_matching('commodities#uk_commodity')).to be_nil
      expect(written_key_matching('commodities#show')).to be_nil
      expect(backend_find_headers).to eq([{ 'Cache-Control' => 'no-store' }] * 2)
    end
  end

  # A heading code on the commodities route is looked up as a heading. The
  # request redirects to the heading page after the backend call.
  #
  # There is no case for today here. A MemoryStore compares a cached value with
  # true, and Heading#== raises when it gets true. The production Redis store
  # does not make this comparison. The cases for another date still show that
  # the backend call ran and that nothing was cached.
  context 'with a heading code on the commodities route' do
    let(:cassette) { 'headings#show' }

    before { record_backend_headers_for(Heading) }

    context 'with the UK service' do
      let(:path) { '/commodities/0101000000' }

      it 'caches nothing and asks the HTTP cache not to store the response for another date', :aggregate_failures do
        get_page(another_date_params, status: :redirect)

        expect(written_key_matching('commodities#uk_heading')).to be_nil
        expect(backend_find_headers).to eq([{ 'Cache-Control' => 'no-store' }])
      end
    end

    context 'with the XI service' do
      let(:path) { '/xi/commodities/0101000000' }

      it 'caches nothing and asks the HTTP cache not to store the response for another date', :aggregate_failures do
        get_page(another_date_params, status: :redirect)

        expect(written_key_matching('commodities#xi_heading')).to be_nil
        expect(backend_find_headers).to eq([{ 'Cache-Control' => 'no-store' }])
      end
    end
  end

  # When the commodity is not found, the code is looked up as a subheading.
  context 'with a subheading code on the commodities route' do
    let(:path) { '/commodities/0101999999' }

    before do
      allow(Commodity).to receive(:find).and_raise(Faraday::ResourceNotFound)
      record_backend_headers_for(Subheading)
      stub_api_request('subheadings/0101999999-80')
        .with(query: hash_including({}))
        .and_return(jsonapi_response(:subheading, attributes_for(:subheading,
                                                                 goods_nomenclature_item_id: '0101999999',
                                                                 producline_suffix: GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX)))
    end

    it 'sends no cache header for today' do
      get_page(todays_date_params, status: :redirect)

      expect(backend_find_headers).to eq([{}])
    end

    it 'asks the HTTP cache not to store the response for another date' do
      get_page(another_date_params, status: :redirect)

      expect(backend_find_headers).to eq([{ 'Cache-Control' => 'no-store' }])
    end
  end
end
