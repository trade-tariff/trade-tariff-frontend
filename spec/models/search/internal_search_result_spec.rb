require 'spec_helper'

RSpec.describe Search::InternalSearchResult do
  def commodity_attrs(overrides = {})
    {
      'goods_nomenclature_item_id' => '0101210000',
      'producline_suffix' => '80',
      'goods_nomenclature_class' => 'Commodity',
      'description' => 'Pure-bred breeding animals',
      'formatted_description' => 'Pure-bred breeding animals',
      'declarable' => true,
      'score' => 12.5,
    }.merge(overrides)
  end

  def heading_attrs(overrides = {})
    {
      'goods_nomenclature_item_id' => '0101000000',
      'producline_suffix' => '80',
      'goods_nomenclature_class' => 'Heading',
      'description' => 'Live horses',
      'formatted_description' => 'Live horses',
      'declarable' => false,
      'score' => 10.0,
    }.merge(overrides)
  end

  def chapter_attrs(overrides = {})
    {
      'goods_nomenclature_item_id' => '0100000000',
      'producline_suffix' => '80',
      'goods_nomenclature_class' => 'Chapter',
      'description' => 'Live animals',
      'formatted_description' => 'Live animals',
      'declarable' => false,
      'score' => 8.0,
    }.merge(overrides)
  end

  def subheading_attrs(overrides = {})
    {
      'goods_nomenclature_item_id' => '0101290000',
      'producline_suffix' => '10',
      'goods_nomenclature_class' => 'Subheading',
      'description' => 'Other horses',
      'formatted_description' => 'Other horses',
      'declarable' => false,
      'score' => 9.0,
    }.merge(overrides)
  end

  describe '#type' do
    context 'with results' do
      subject { described_class.new([commodity_attrs]).type }

      it { is_expected.to eq('internal') }
    end

    context 'with empty results' do
      subject { described_class.new([]).type }

      it { is_expected.to be_nil }
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

    context 'with no results' do
      subject { described_class.new([]) }

      it { is_expected.not_to be_exact_match }
    end
  end

  describe '#to_param' do
    context 'when exact match for a Commodity' do
      subject { described_class.new([commodity_attrs('score' => nil)]).to_param }

      it { is_expected.to eq(controller: 'commodities', action: :show, id: '0101210000') }
    end

    context 'when exact match for a Heading' do
      subject { described_class.new([heading_attrs('score' => nil)]).to_param }

      it { is_expected.to eq(controller: 'headings', action: :show, id: '0101') }
    end

    context 'when exact match for a Chapter' do
      subject { described_class.new([chapter_attrs('score' => nil)]).to_param }

      it { is_expected.to eq(controller: 'chapters', action: :show, id: '01') }
    end

    context 'when exact match for a Subheading' do
      subject { described_class.new([subheading_attrs('score' => nil)]).to_param }

      it { is_expected.to eq(controller: 'subheadings', action: :show, id: '0101290000-10') }
    end

    context 'when not an exact match' do
      subject { described_class.new([commodity_attrs, heading_attrs]).to_param }

      it { is_expected.to eq({}) }
    end
  end

  describe '#any?' do
    context 'with results' do
      subject { described_class.new([commodity_attrs]) }

      it { is_expected.to be_any }
    end

    context 'with empty results' do
      subject { described_class.new([]) }

      it { is_expected.not_to be_any }
    end
  end

  describe '#none?' do
    context 'with results' do
      subject { described_class.new([commodity_attrs]) }

      it { is_expected.not_to be_none }
    end

    context 'with empty results' do
      subject { described_class.new([]) }

      it { is_expected.to be_none }
    end
  end

  describe '#commodities' do
    it 'returns only declarable Commodity instances', :aggregate_failures do
      result = described_class.new([
        commodity_attrs('declarable' => true),
        commodity_attrs('declarable' => false, 'goods_nomenclature_item_id' => '0101220000'),
        heading_attrs,
      ])

      expect(result.commodities).to all(be_a(Commodity))
      expect(result.commodities.size).to eq(1)
    end

    it 'caps results at legacy_results_to_show' do
      entries = 10.times.map do |i|
        commodity_attrs('goods_nomenclature_item_id' => sprintf('01012%05d', i))
      end
      result = described_class.new(entries)

      expect(result.commodities.size).to be <= TradeTariffFrontend.legacy_results_to_show
    end
  end

  describe '#reference_matches_by_chapter' do
    subject { described_class.new([commodity_attrs]).reference_matches_by_chapter }

    it { is_expected.to eq([]) }
  end

  describe '#gn_matches_without_duplicates_by_chapter' do
    subject { described_class.new([commodity_attrs]).gn_matches_without_duplicates_by_chapter }

    it { is_expected.to eq([]) }
  end

  describe '#reference_match' do
    subject { described_class.new([commodity_attrs]).reference_match }

    it { is_expected.to eq(Search::ReferenceMatch::BLANK_RESULT) }
  end

  describe '#goods_nomenclature_match' do
    subject { described_class.new([commodity_attrs]).goods_nomenclature_match }

    it { is_expected.to eq(Search::GoodsNomenclatureMatch::BLANK_RESULT) }
  end

  describe '#all' do
    it 'returns all results' do
      result = described_class.new([commodity_attrs, heading_attrs])

      expect(result.all.size).to eq(2)
    end
  end

  describe '#size' do
    it 'delegates to all' do
      result = described_class.new([commodity_attrs, heading_attrs, chapter_attrs])

      expect(result.size).to eq(3)
    end
  end

  describe 'build_model' do
    it 'instantiates a Commodity for goods_nomenclature_class Commodity' do
      result = described_class.new([commodity_attrs])

      expect(result.all.first).to be_a(Commodity)
    end

    it 'instantiates a Heading for goods_nomenclature_class Heading' do
      result = described_class.new([heading_attrs])

      expect(result.all.first).to be_a(Heading)
    end

    it 'instantiates a Chapter for goods_nomenclature_class Chapter' do
      result = described_class.new([chapter_attrs])

      expect(result.all.first).to be_a(Chapter)
    end

    it 'instantiates a Subheading for goods_nomenclature_class Subheading' do
      result = described_class.new([subheading_attrs])

      expect(result.all.first).to be_a(Subheading)
    end

    it 'falls back to GoodsNomenclature for unknown class' do
      attrs = commodity_attrs('goods_nomenclature_class' => 'UnknownThing')
      result = described_class.new([attrs])

      expect(result.all.first).to be_a(GoodsNomenclature)
    end
  end
end
