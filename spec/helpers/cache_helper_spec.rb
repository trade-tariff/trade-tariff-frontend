RSpec.describe CacheHelper, type: :helper do
  describe '#commodity_cache_key' do
    let(:cacheable) do
      Class.new do
        include CacheHelper
        attr_accessor :tariff_last_updated, :params

        def initialize(last_updated, params_hash)
          @tariff_last_updated = last_updated
          @params = ActionController::Parameters.new(params_hash)
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

    context 'when date params are available, builds the correct commodity cache key' do
      let(:instance) { cacheable.new('2025-01-01', { day: '04', month: '01', year: '2025', id: '2008605010' }) }

      it { expect(instance.commodity_cache_key).to eq(%w[commodities#show uk/2025-01-01/1 100 04/2008605010/01/2025]) }
    end

    context 'when date and month swapped for subsequent requests, cache keys are different' do
      let(:instance) { cacheable.new('2025-01-01', { day: '04', month: '01', year: '2025', id: '2008605010' }) }
      let(:instance2) { cacheable.new('2025-01-01', { day: '01', month: '04', year: '2025', id: '2008605010' }) }

      it { expect(instance.commodity_cache_key).not_to eq(instance2.commodity_cache_key) }
    end

    context 'when request_id is present, it is excluded from the cache key' do
      let(:without_request_id) { cacheable.new('2025-01-01', { day: '04', month: '01', year: '2025', id: '2008605010' }) }
      let(:with_request_id) { cacheable.new('2025-01-01', { day: '04', month: '01', year: '2025', id: '2008605010', request_id: SecureRandom.uuid }) }

      it { expect(with_request_id.commodity_cache_key).to eq(without_request_id.commodity_cache_key) }
    end
  end
end
