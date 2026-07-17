require 'spec_helper'

RSpec.describe Search::HybridOutcome do
  def commodity_attrs(overrides = {})
    {
      'goods_nomenclature_item_id' => '0712903000',
      'producline_suffix' => '80',
      'goods_nomenclature_class' => 'Commodity',
      'description' => 'Tomatoes',
      'declarable' => true,
      'score' => 31.752518,
    }.merge(overrides)
  end

  def heading_attrs(overrides = {})
    {
      'goods_nomenclature_item_id' => '0100000000',
      'producline_suffix' => '80',
      'goods_nomenclature_class' => 'Heading',
      'description' => 'Live animals',
      'declarable' => true,
      'score' => 12.5,
    }.merge(overrides)
  end

  def chapter_attrs(overrides = {})
    {
      'goods_nomenclature_item_id' => '0200000000',
      'producline_suffix' => '80',
      'goods_nomenclature_class' => 'Chapter',
      'description' => 'Meat',
      'declarable' => true,
      'score' => 9.0,
    }.merge(overrides)
  end

  describe '#commodities' do
    subject(:commodities) { described_class.new(parsed_data).commodities }

    let(:parsed_data) do
      [
        commodity_attrs,
        commodity_attrs('goods_nomenclature_item_id' => '0712909000', 'description' => 'Mushrooms'),
        heading_attrs,
        commodity_attrs('declarable' => false, 'goods_nomenclature_item_id' => '0101210000'),
      ]
    end

    it 'returns only commodities' do
      expect(commodities).to all(be_a(Commodity))
    end

    it 'returns only declarable' do
      expect(commodities).to all(have_attributes(declarable: true))
    end

    it 'returns correct attributes' do
      expect(commodities.map(&:goods_nomenclature_item_id)).to eq(%w[0712903000 0712909000])
    end

    it 'limits results to the configured hybrid results count' do
      allow(TradeTariffFrontend).to receive(:hybrid_results_to_show).and_return(1)

      expect(commodities.size).to eq(1)
    end
  end

  describe '#exact_match?' do
    context 'with a single result with nil score' do
      subject { described_class.new([commodity_attrs('score' => nil)]) }

      it { is_expected.to be_exact_match }
    end

    context 'with a single result with a numeric score' do
      subject { described_class.new([commodity_attrs('score' => 12.5)]) }

      it { is_expected.not_to be_exact_match }
    end

    context 'with multiple results' do
      subject { described_class.new([commodity_attrs, heading_attrs]) }

      it { is_expected.not_to be_exact_match }
    end
  end

  describe '#exact_match' do
    subject(:exact_match) { described_class.new(parsed_data).exact_match }

    let(:parsed_data) { [commodity_attrs('goods_nomenclature_item_id' => '0101210000')] }

    it 'returns the first parsed result' do
      expect(exact_match.goods_nomenclature_item_id).to eq('0101210000')
    end
  end

  describe '#entry' do
    context 'when the result is an exact match' do
      subject(:entry) { described_class.new([commodity_attrs('score' => nil)]).entry }

      it 'returns the entry payload for the exact match' do
        expect(entry).to eq('id' => '0712903000', 'endpoint' => 'commodities')
      end
    end

    context 'when the result is not an exact match' do
      subject(:entry) { described_class.new([commodity_attrs('score' => 12.5), heading_attrs]).entry }

      it { is_expected.to be_nil }
    end
  end

  describe '#goods_nomenclature_match' do
    context 'when the search is an exact match' do
      let(:outcome) { described_class.new([commodity_attrs('score' => nil)]) }

      it 'returns the blank goods nomenclature match result' do
        expect(outcome.goods_nomenclature_match).to eq(Search::GoodsNomenclatureMatch::BLANK_RESULT)
      end
    end

    context 'when the search is not an exact match' do
      let(:outcome) { described_class.new([commodity_attrs('score' => 12.5), heading_attrs]) }

      it 'builds a goods nomenclature match from the hybrid commodities' do
        expect(outcome.goods_nomenclature_match.commodities).to all(be_a(Commodity))
      end
    end
  end

  describe 'v2 compatibility shims' do
    subject(:outcome) { described_class.new([commodity_attrs, heading_attrs, chapter_attrs]) }

    it 'exposes blank reference matches' do
      expect(outcome.reference_match).to eq(Search::ReferenceMatch::BLANK_RESULT)
    end

    it 'exposes blank goods nomenclature matches' do
      expect(outcome.goods_nomenclature_match).to eq(Search::GoodsNomenclatureMatch::BLANK_RESULT)
    end

    it 'returns empty chapter-grouped reference result collections' do
      expect(outcome.reference_matches_by_chapter).to eq([])
    end

    it 'returns empty chapter-grouped gn result collections' do
      expect(outcome.gn_matches_without_duplicates_by_chapter).to eq([])
    end

    it 'does not behave like interactive search' do
      expect(outcome.interactive_search?).to be(false)
    end
  end

  describe '#all' do
    subject(:all_results) { described_class.new(parsed_data).all }

    let(:parsed_data) { [commodity_attrs, heading_attrs, chapter_attrs] }

    it 'builds typed goods nomenclature models from internal search data' do
      expect(all_results).to contain_exactly(
        an_instance_of(Commodity),
        an_instance_of(Heading),
        an_instance_of(Chapter),
      )
    end

    it 'falls back to GoodsNomenclature for unknown classes' do
      outcome = described_class.new([
        commodity_attrs('goods_nomenclature_class' => 'UnknownClass'),
      ])

      expect(outcome.all.first).to be_a(GoodsNomenclature)
    end
  end

  describe 'result presence' do
    it 'delegates any? parsed results' do
      expect(described_class.new([commodity_attrs]).any?).to be(true)
    end

    it 'delegates none? to parsed results' do
      expect(described_class.new([commodity_attrs]).none?).to be(false)
    end

    it 'delegates size to all results' do
      expect(described_class.new([commodity_attrs, heading_attrs]).size).to eq(2)
    end
  end
end
