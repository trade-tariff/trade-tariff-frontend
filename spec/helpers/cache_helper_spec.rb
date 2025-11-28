RSpec.describe CacheHelper, type: :helper do
  describe '#commodity_cache_key' do
    let(:cacheable) do
      Class.new do
        include CacheHelper
        attr_accessor :tariff_last_updated

        def initialize(last_updated)
          @tariff_last_updated = last_updated
        end
      end
    end

    subject(:instance) { cacheable.new("2025-01-01") }

    before do
      allow(TradeTariffFrontend::ServiceChooser).to receive(:cache_prefix).and_return('uk')
      allow(TradeTariffFrontend).to receive(:revision).and_return('1')
      allow(instance).to receive(:meursing_lookup_result).and_return(double(meursing_additional_code_id: "100"))
      allow(instance).to receive(:params).and_return(ActionController::Parameters.new(params_hash))
    end

    context 'when date params are available, builds the correct commodity cache key' do
      let(:params_hash) { {day: '04', month: '01', year: '2025', id: '2008605010'} }

      it { expect(instance.commodity_cache_key).to eq(%W[commodities#show uk/2025-01-01/1 100 04/2008605010/01/2025]) }
    end

    context 'when date and month swapped for subsequent requests, cache keys are different' do
      let(:params_hash) { {day: '01', month: '04', year: '2025', id: '2008605010'} }

      it { expect(instance.commodity_cache_key).to eq(%W[commodities#show uk/2025-01-01/1 100 01/2008605010/04/2025]) }
    end
  end
end
