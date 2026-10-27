RSpec.describe 'Search tracking during tariff browsing', type: :request do
  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))
    allow(GeographicalArea).to receive(:all).and_return([])
    allow(RulesOfOrigin::Scheme).to receive_messages(for_heading_and_country: [], all: [])
    allow(DeclarableUnitService).to receive(:new).and_return(instance_double(DeclarableUnitService, call: 'No supplementary units'))
  end

  shared_context 'with page caching enabled' do
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

    before { allow(Rails).to receive(:cache).and_return(ActionController::Base.cache_store) }
  end

  shared_examples 'untracked browsing navigation' do
    include_context 'with page caching enabled'

    it 'does not propagate tracking to navigation', :aggregate_failures do
      VCR.use_cassette(cassette) do
        get path, params: { request_id: 'search-123' }
      end

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML(response.body)
      navigation = document.css('a[href], [data-lazy-tab-url-value], form[action]').filter_map do |element|
        url = element['href'] || element['data-lazy-tab-url-value'] || element['action']
        next if URI.parse(url).path&.match?(%r{\A/(?:xi/)?(feedback|enquiry_form)\b})

        url if url.include?('request_id') || url.include?('search-123')
      end
      expect(navigation).to be_empty
      expect(document.css('.country-picker input[name="request_id"]')).to be_empty
    end

    it 'does not cache tracking params for later visitors', :aggregate_failures do
      VCR.use_cassette(cassette, allow_playback_repeats: true) do
        get path, params: { utm_source: 'newsletter-abc', _ga: 'GA1.2.3-abc', fbclid: 'fb-abc' }
        get path
      end

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('newsletter-abc', 'GA1.2.3-abc', 'fb-abc')
    end

    it 'does not cache tracking for later visitors', :aggregate_failures do
      VCR.use_cassette(cassette, allow_playback_repeats: true) do
        get path, params: { request_id: 'search-123' }
        get path
      end

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('search-123')
    end
  end

  [
    ['/browse', 'sections#index', '/sections/'],
    ['/sections/1', 'sections#show', '/chapters/'],
    ['/chapters/01', 'chapters#show', '/headings/'],
  ].each do |path, cassette, destination|
    context "when browsing #{path}" do
      it 'does not track onward links', :aggregate_failures do
        VCR.use_cassette(cassette) do
          get path, params: { request_id: 'search-123' }
        end

        expect(response).to have_http_status(:ok)
        links = Nokogiri::HTML(response.body).css("a[href^='#{destination}']")
        expect(links).not_to be_empty
        expect(links.map { |link| link['href'] }).not_to include(a_string_including('request_id'))
      end
    end
  end

  context 'with a heading' do
    let(:path) { '/headings/0101' }
    let(:cassette) { 'headings#show' }

    include_examples 'untracked browsing navigation'
  end

  context 'with a UK commodity' do
    let(:path) { '/commodities/0101300000' }
    let(:cassette) { 'commodities#0101300000#uk' }

    include_examples 'untracked browsing navigation'
  end

  context 'with an XI commodity' do
    let(:path) { '/xi/commodities/0101300000' }
    let(:cassette) { 'commodities#0101300000#xi' }

    include_examples 'untracked browsing navigation'
  end

  describe 'date inputs on a cached commodity page' do
    include_context 'with page caching enabled'

    let(:path) { '/commodities/0101300000' }
    let(:cassette) { 'commodities#0101300000#uk' }
    let(:as_of_parts) { { 'as_of(1i)' => '2025', 'as_of(2i)' => '1', 'as_of(3i)' => '4' } }
    let(:canonical_date) { { day: '4', month: '1', year: '2025' } }

    def date_input_values(body)
      Nokogiri::HTML(body).css('.govuk-date-input input').to_h { |input| [input['name'], input['value']] }
    end

    it 'does not let as_of parts fill the cache for a later canonical date request', :aggregate_failures do
      VCR.use_cassette(cassette, allow_playback_repeats: true) do
        get path, params: as_of_parts
        get path, params: canonical_date
      end

      expect(response).to have_http_status(:ok)
      expect(date_input_values(response.body)).to eq('day' => '4', 'month' => '1', 'year' => '2025')
      expect(Nokogiri::HTML(response.body).css('#commodity-ancestors__section a').first['href']).to include('year=2025')
    end

    it 'does not let blank date params plus as_of parts fill the cache for a later canonical date request', :aggregate_failures do
      VCR.use_cassette(cassette, allow_playback_repeats: true) do
        get path, params: { day: '', month: '', year: '' }.merge(as_of_parts)
        get path, params: canonical_date
      end

      expect(response).to have_http_status(:ok)
      expect(date_input_values(response.body)).to eq('day' => '4', 'month' => '1', 'year' => '2025')
    end

    it 'keeps the date in navigation links when the date is only in the nested search params', :aggregate_failures do
      VCR.use_cassette(cassette) do
        get path, params: { search: canonical_date }
      end

      links = Nokogiri::HTML(response.body).css('[data-lazy-tab-url-value], a[href*="/origin"]')
      urls = links.filter_map { |element| element['data-lazy-tab-url-value'] || element['href'] }

      expect(urls).not_to be_empty
      expect(urls).to all(include('year=2025'))
    end
  end
end
