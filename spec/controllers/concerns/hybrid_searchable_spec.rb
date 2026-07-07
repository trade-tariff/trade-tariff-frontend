require 'spec_helper'

RSpec.describe HybridSearchable do
  controller(SearchController) {}

  let(:commodity_data) do
    {
      'goods_nomenclature_item_id' => '0101210000',
      'producline_suffix' => GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
      'goods_nomenclature_class' => 'Commodity',
      'description' => 'Pure-bred breeding animals',
      'formatted_description' => 'Pure-bred breeding animals',
      'declarable' => true,
      'score' => nil,
    }
  end

  before do
    disable_feature(:interactive_search)
    enable_feature(:hybrid_search)
    Current.flagsmith_identity = Flagsmith::AnonymousIdentity.new('anon-123')
    controller.instance_variable_set(:@search, Search.new(q: '0101210000', request_id: 'hybrid-request-id'))
    allow(controller).to receive(:redirect_to)
  end

  describe '#hybrid_search?' do
    it 'reflects the hybrid search feature flag' do
      expect(controller.send(:hybrid_search?)).to be(true)
    end
  end

  describe '#route_hybrid_results' do
    before do
      controller.instance_variable_set(:@results, Search::HybridOutcome.new([commodity_data]))
    end

    it 'redirects exact matches to the matched goods nomenclature page' do
      controller.send(:route_hybrid_results)

      expect(controller).to have_received(:redirect_to).with(
        commodity_path('0101210000', request_id: 'hybrid-request-id'),
      )
    end

    context 'when the outcome is not an exact match' do
      before do
        controller.instance_variable_set(
          :@results,
          Search::HybridOutcome.new([commodity_data.merge('score' => 12.5)]),
        )
      end

      it 'does not redirect' do
        controller.send(:route_hybrid_results)

        expect(controller).not_to have_received(:redirect_to)
      end
    end
  end
end
