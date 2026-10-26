RSpec.describe CacheHelper, type: :helper do
  let(:cacheable) do
    Class.new do
      include CacheHelper
      attr_accessor :params, :request

      def initialize(params_hash)
        @params = ActionController::Parameters.new(params_hash)
        @request = Struct.new(:query_parameters).new(params_hash.except(:id, :controller, :action).stringify_keys)
      end

      def meursing_lookup_result
        MeursingLookup::Result.new(meursing_additional_code_id: '100')
      end
    end
  end

  before do
    allow(TradeTariffFrontend::ServiceChooser).to receive(:cache_prefix).and_return('uk')
    allow(TradeTariffFrontend).to receive(:revision).and_return('1')
  end

  describe '#commodity_cache_key' do
    context 'when date params are available, builds the correct commodity cache key' do
      let(:instance) { cacheable.new({ day: '04', month: '01', year: '2025', id: '2008605010' }) }

      it { expect(instance.commodity_cache_key).to eq(%w[commodities#show uk/1 100 day=04&id=2008605010&month=01&year=2025]) }
    end

    context 'when date and month swapped for subsequent requests, cache keys are different' do
      let(:instance) { cacheable.new({ day: '04', month: '01', year: '2025', id: '2008605010' }) }
      let(:instance2) { cacheable.new({ day: '01', month: '04', year: '2025', id: '2008605010' }) }

      it { expect(instance.commodity_cache_key).not_to eq(instance2.commodity_cache_key) }
    end

    context 'when request_id is present, it is excluded from the cache key' do
      let(:without_request_id) { cacheable.new({ day: '04', month: '01', year: '2025', id: '2008605010' }) }
      let(:with_request_id) { cacheable.new({ day: '04', month: '01', year: '2025', id: '2008605010', request_id: SecureRandom.uuid }) }

      it { expect(with_request_id.commodity_cache_key).to eq(without_request_id.commodity_cache_key) }
    end

    context 'when tracking params that do not change the page are present' do
      let(:plain) { cacheable.new({ id: '2008605010', country: 'US' }) }
      let(:tracked) { cacheable.new({ id: '2008605010', country: 'US', utm_source: 'a', _ga: 'b', fbclid: 'c', 'amp;country': 'US' }) }

      it 'gives the same key as the plain request' do
        expect(tracked.commodity_cache_key).to eq(plain.commodity_cache_key)
      end
    end

    context 'when two different params have the same value' do
      let(:country_request) { cacheable.new({ id: '2008605010', country: 'US' }) }
      let(:highlight_request) { cacheable.new({ id: '2008605010', t: 'US' }) }

      it 'gives different keys, because the key includes the param names' do
        expect(country_request.commodity_cache_key).not_to eq(highlight_request.commodity_cache_key)
      end
    end

    context 'when the country differs only by letter case' do
      let(:lower) { cacheable.new({ id: '2008605010', country: 'us' }) }
      let(:upper) { cacheable.new({ id: '2008605010', country: 'US' }) }

      it 'gives different keys, because the page still uses the raw country value' do
        expect(lower.commodity_cache_key).not_to eq(upper.commodity_cache_key)
      end
    end

    context 'when a value contains the key separators' do
      let(:escaped) { cacheable.new({ id: '0101', t: 'horse/year=2025' }) }
      let(:separate) { cacheable.new({ id: '0101', t: 'horse', year: '2025' }) }
      let(:ampersand) { cacheable.new({ id: '0101', t: 'horse&year=2025' }) }

      it 'gives different keys, because names and values are escaped', :aggregate_failures do
        expect(escaped.commodity_cache_key).not_to eq(separate.commodity_cache_key)
        expect(ampersand.commodity_cache_key).not_to eq(separate.commodity_cache_key)
      end
    end

    context 'when the date params are blank' do
      let(:blank) { cacheable.new({ id: '2008605010', day: '', month: '', year: '' }) }
      let(:undated) { cacheable.new({ id: '2008605010' }) }

      it 'gives a different key, because the date fields render blank instead of today' do
        expect(blank.commodity_cache_key).not_to eq(undated.commodity_cache_key)
      end
    end

    context 'when the highlight term is present' do
      let(:plain) { cacheable.new({ id: '2008605010' }) }
      let(:highlighted) { cacheable.new({ id: '2008605010', t: 'olive' }) }

      it 'gives a different key, because the term is rendered in the page' do
        expect(highlighted.commodity_cache_key).not_to eq(plain.commodity_cache_key)
      end
    end

    context 'when the commodity search link is hidden' do
      let(:instance) { cacheable.new({ day: '04', month: '01', year: '2025', id: '2008605010' }) }

      it 'includes shared search' do
        expect(instance.commodity_cache_key(show_commodity_search_link: false)).to eq(
          %w[commodities#show uk/1 100 shared-search day=04&id=2008605010&month=01&year=2025],
        )
      end
    end

    context 'when the commodity search link is shown' do
      let(:instance) { cacheable.new({ day: '04', month: '01', year: '2025', id: '2008605010' }) }

      it 'includes guided search link' do
        expect(instance.commodity_cache_key(show_commodity_search_link: true)).to eq(
          %w[commodities#show uk/1 100 guided-search-link day=04&id=2008605010&month=01&year=2025],
        )
      end
    end
  end

  describe '#heading_cache_key' do
    it 'ignores tracking params and includes param names' do
      instance = cacheable.new({ id: '0101', country: 'FR', utm_source: 'a' })

      expect(instance.heading_cache_key).to eq(%w[headings#show uk/1 country=FR&id=0101])
    end
  end

  describe '#canonical_date_params?' do
    it 'is true for plain day, month and year params' do
      expect(cacheable.new({ id: '0101', day: '1', month: '2', year: '2025' })).to be_canonical_date_params
    end

    it 'is true when there is no date' do
      expect(cacheable.new({ id: '0101' })).to be_canonical_date_params
    end

    it 'is false for as_of date parts, which render different fields and links', :aggregate_failures do
      expect(cacheable.new({ id: '0101', 'as_of(1i)': '2025' })).not_to be_canonical_date_params
      expect(cacheable.new({ id: '0101', 'as_of(year)': '2025' })).not_to be_canonical_date_params
    end
  end

  describe '#cacheable_query_params' do
    it 'keeps only the params that change the page' do
      instance = cacheable.new({ id: '0101', day: '1', month: '2', year: '2025', country: 'FR', t: 'olive', utm_source: 'a', _ga: 'b', q: 'x' })

      expect(instance.cacheable_query_params).to eq(
        'day' => '1', 'month' => '2', 'year' => '2025', 'country' => 'FR', 't' => 'olive',
      )
    end

    it 'does not include the route id, which would clash with the link path' do
      instance = cacheable.new({ id: '0101', country: 'FR' })

      expect(instance.cacheable_query_params).not_to have_key('id')
    end

    it 'turns as_of date parts into day, month and year, so links match the key' do
      instance = cacheable.new({ id: '0101' })

      expect(instance.cacheable_query_params({ 'as_of(3i)' => '4', 'as_of(2i)' => '1', 'as_of(1i)' => '2025' })).to eq(
        'day' => '4', 'month' => '1', 'year' => '2025',
      )
    end

    it 'reads the date from the nested search hash, as the controller does' do
      instance = cacheable.new({ id: '0101' })
      nested = { 'search' => { 'day' => '4', 'month' => '1', 'year' => '2025', 'country' => 'FR' }, 'utm_source' => 'a' }

      expect(instance.cacheable_query_params(nested)).to eq(
        'day' => '4', 'month' => '1', 'year' => '2025', 'country' => 'FR',
      )
    end

    it 'accepts a given hash of query params' do
      instance = cacheable.new({ id: '0101' })

      expect(instance.cacheable_query_params({ 'country' => 'FR', 'utm_source' => 'a' })).to eq('country' => 'FR')
    end
  end
end
