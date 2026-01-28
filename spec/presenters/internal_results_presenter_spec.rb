require 'spec_helper'

RSpec.describe InternalResultsPresenter do
  subject(:presenter) { described_class.new(search, search_results) }

  let(:search) { Search.new(q: 'horses') }

  describe '#as_json' do
    context 'with mixed result types' do
      let(:search_results) do
        Search::InternalSearchResult.new([
          {
            'goods_nomenclature_item_id' => '0101210000',
            'producline_suffix' => '80',
            'goods_nomenclature_class' => 'Commodity',
            'description' => 'Pure-bred breeding animals',
            'formatted_description' => 'Pure-bred breeding animals',
            'declarable' => true,
            'score' => 12.5,
          },
          {
            'goods_nomenclature_item_id' => '0101000000',
            'producline_suffix' => '80',
            'goods_nomenclature_class' => 'Heading',
            'description' => 'Live horses',
            'formatted_description' => 'Live horses',
            'declarable' => false,
            'score' => 10.0,
          },
        ])
      end

      let(:json) { presenter.as_json }

      it 'returns an array of results', :aggregate_failures do
        expect(json).to be_an(Array)
        expect(json.size).to eq(2)
      end

      it 'serializes commodity attributes', :aggregate_failures do
        commodity_json = json.first

        expect(commodity_json[:type]).to eq('commodity')
        expect(commodity_json[:goods_nomenclature_item_id]).to eq('0101210000')
        expect(commodity_json[:description]).to eq('Pure-bred breeding animals')
        expect(commodity_json[:formatted_description]).to eq('Pure-bred breeding animals')
        expect(commodity_json[:declarable]).to be true
        expect(commodity_json[:score]).to eq(12.5)
      end

      it 'serializes heading attributes', :aggregate_failures do
        heading_json = json.second

        expect(heading_json[:type]).to eq('heading')
        expect(heading_json[:goods_nomenclature_item_id]).to eq('0101000000')
        expect(heading_json[:declarable]).to be false
        expect(heading_json[:score]).to eq(10.0)
      end
    end

    context 'with empty results' do
      let(:search_results) { Search::InternalSearchResult.new([]) }

      it 'returns an empty array' do
        expect(presenter.as_json).to eq([])
      end
    end
  end
end
