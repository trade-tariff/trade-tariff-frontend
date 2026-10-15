require 'spec_helper'

RSpec.describe Search::InternalSearchResult do
  def commodity_attrs(overrides = {})
    {
      'goods_nomenclature_item_id' => '0101210000',
      'producline_suffix' => GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
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
      'producline_suffix' => GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
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
      'producline_suffix' => GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
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

      it { is_expected.to eq('internal') }
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

  describe '#interactive_search?' do
    context 'with interactive_search meta' do
      subject { described_class.new([commodity_attrs], meta) }

      let(:meta) { { 'interactive_search' => { 'query' => 'test', 'request_id' => 'abc-123' } } }

      it { is_expected.to be_interactive_search }
    end

    context 'without meta' do
      subject { described_class.new([commodity_attrs]) }

      it { is_expected.not_to be_interactive_search }
    end

    context 'with nil meta' do
      subject { described_class.new([commodity_attrs], nil) }

      it { is_expected.not_to be_interactive_search }
    end
  end

  describe '#search_failures' do
    it 'returns the failure codes from top-level response metadata' do
      result = described_class.new(
        [commodity_attrs],
        { 'search_failures' => %w[query_expansion_failed opensearch_failed] },
      )

      expect(result.search_failures).to eq(%w[query_expansion_failed opensearch_failed])
    end

    it 'returns an empty array when response metadata has no failure codes' do
      result = described_class.new([commodity_attrs], nil)

      expect(result.search_failures).to eq([])
    end
  end

  describe '#has_pending_question?' do
    context 'when last answer has nil answer' do
      subject { described_class.new([commodity_attrs], meta) }

      let(:meta) do
        {
          'interactive_search' => {
            'answers' => [
              { 'question' => 'Q1?', 'options' => %w[A B], 'answer' => 'A' },
              { 'question' => 'Q2?', 'options' => %w[C D], 'answer' => nil },
            ],
          },
        }
      end

      it { is_expected.to have_pending_question }
    end

    context 'when all answers are filled' do
      subject { described_class.new([commodity_attrs], meta) }

      let(:meta) do
        {
          'interactive_search' => {
            'answers' => [
              { 'question' => 'Q1?', 'options' => %w[A B], 'answer' => 'A' },
            ],
          },
        }
      end

      it { is_expected.not_to have_pending_question }
    end

    context 'when answers is empty' do
      subject { described_class.new([commodity_attrs], meta) }

      let(:meta) { { 'interactive_search' => { 'answers' => [] } } }

      it { is_expected.not_to have_pending_question }
    end

    context 'without interactive_search meta' do
      subject { described_class.new([commodity_attrs]) }

      it { is_expected.not_to have_pending_question }
    end
  end

  describe '#current_question' do
    context 'when has pending question' do
      subject { described_class.new([commodity_attrs], meta).current_question }

      let(:pending_question) { { 'question' => 'Q2?', 'options' => %w[C D], 'answer' => nil } }
      let(:meta) do
        {
          'interactive_search' => {
            'answers' => [
              { 'question' => 'Q1?', 'options' => %w[A B], 'answer' => 'A' },
              pending_question,
            ],
          },
        }
      end

      it { is_expected.to eq(pending_question) }
    end

    context 'when no pending question' do
      subject { described_class.new([commodity_attrs], meta).current_question }

      let(:meta) do
        {
          'interactive_search' => {
            'answers' => [
              { 'question' => 'Q1?', 'options' => %w[A B], 'answer' => 'A' },
            ],
          },
        }
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#request_id' do
    subject { described_class.new([commodity_attrs], meta).request_id }

    let(:meta) { { 'interactive_search' => { 'request_id' => 'abc-123' } } }

    it { is_expected.to eq('abc-123') }
  end

  describe '#answered_questions' do
    subject(:answered) { described_class.new([commodity_attrs], meta).answered_questions }

    let(:meta) do
      {
        'interactive_search' => {
          'answers' => [
            { 'question' => 'Q1?', 'options' => %w[A B], 'answer' => 'A' },
            { 'question' => 'Q2?', 'options' => %w[C D], 'answer' => nil },
          ],
        },
      }
    end

    it 'returns correct count' do
      expect(answered.size).to eq(1)
    end

    it 'includes only answered questions' do
      expect(answered.first['question']).to eq('Q1?')
    end
  end

  describe '#result_limit' do
    context 'when set in meta' do
      subject { described_class.new([commodity_attrs], meta).result_limit }

      let(:meta) { { 'interactive_search' => { 'result_limit' => 3 } } }

      it { is_expected.to eq(3) }
    end

    context 'when not set in meta' do
      subject { described_class.new([commodity_attrs], meta).result_limit }

      let(:meta) { { 'interactive_search' => {} } }

      it { is_expected.to eq(5) }
    end

    context 'without meta' do
      subject { described_class.new([commodity_attrs]).result_limit }

      it { is_expected.to eq(5) }
    end
  end

  describe '#all_unknown_confidence?' do
    context 'when every result has unknown confidence' do
      subject { described_class.new([commodity_attrs('confidence' => 'unknown'), heading_attrs('confidence' => nil)]) }

      it { is_expected.to be_all_unknown_confidence }
    end

    context 'when any result has recognised confidence' do
      subject { described_class.new([commodity_attrs('confidence' => 'possible'), heading_attrs('confidence' => 'unknown')]) }

      it { is_expected.not_to be_all_unknown_confidence }
    end

    context 'when there are no results' do
      subject { described_class.new([]) }

      it { is_expected.not_to be_all_unknown_confidence }
    end
  end

  describe '#query' do
    subject { described_class.new([commodity_attrs], meta).query }

    let(:meta) { { 'interactive_search' => { 'query' => 'leather handbag' } } }

    it { is_expected.to eq('leather handbag') }
  end

  describe '#expanded_query' do
    subject { described_class.new([commodity_attrs], meta).expanded_query }

    let(:meta) { { 'interactive_search' => { 'expanded_query' => 'leather handbag travel bag' } } }

    it { is_expected.to eq('leather handbag travel bag') }
  end

  describe '#query_expansion' do
    subject(:result) { described_class.new([commodity_attrs], meta) }

    let(:meta) do
      {
        'interactive_search' => {
          'expanded_query' => 'leather handbag',
          'query_expansion' => expansion,
        },
      }
    end
    let(:expansion) { { 'ai_terms' => %w[handbag], 'other' => 'ignored' } }

    it 'returns only the expansion terms' do
      expect(result.query_expansion).to eq('ai_terms' => %w[handbag])
    end

    it 'keeps a known-empty term list', :aggregate_failures do
      meta['interactive_search']['query_expansion'] = { 'ai_terms' => [] }

      expect(result.query_expansion).to eq('ai_terms' => [])
      expect(result.query_expansion_json).to eq('{"ai_terms":[]}')
    end

    it 'drops invalid expansion data and keeps the result', :aggregate_failures do
      meta['interactive_search']['query_expansion'] = { 'ai_terms' => [''] }

      expect(result.query_expansion).to be_nil
      expect(result.expanded_query).to eq('leather handbag')
      expect(result.meta['interactive_search']).not_to have_key('query_expansion')
    end

    it 'treats missing expansion data as unknown' do
      meta['interactive_search'].delete('query_expansion')

      expect(result.query_expansion).to be_nil
    end
  end

  describe '#description_intercept' do
    it 'returns the description_intercept hash from meta when present' do
      meta = { 'description_intercept' => { 'excluded' => true, 'message_header' => 'Sending a set', 'message' => 'Sets...' } }
      result = described_class.new([], meta)
      expect(result.description_intercept).to eq(meta['description_intercept'])
    end

    it 'returns nil when no description_intercept in meta' do
      result = described_class.new([], { 'interactive_search' => {} })
      expect(result.description_intercept).to be_nil
    end
  end

  describe '#blocking_guidance?' do
    it 'returns true when excluded is true and both message_header and message are present' do
      meta = { 'description_intercept' => { 'excluded' => true, 'message_header' => 'Sending a set', 'message' => 'Sets should be...' } }
      result = described_class.new([], meta)
      expect(result.blocking_guidance?).to be true
    end

    it 'returns false when excluded is false even if message present' do
      meta = { 'description_intercept' => { 'excluded' => false, 'message_header' => 'Foo', 'message' => 'Bar' } }
      result = described_class.new([], meta)
      expect(result.blocking_guidance?).to be false
    end

    it 'returns false when message_header is missing' do
      meta = { 'description_intercept' => { 'excluded' => true, 'message' => 'Only body' } }
      result = described_class.new([], meta)
      expect(result.blocking_guidance?).to be false
    end
  end

  describe '#description_intercept_message_header' do
    it 'returns the message_header from the intercept' do
      meta = { 'description_intercept' => { 'message_header' => 'Sending a set' } }
      result = described_class.new([], meta)
      expect(result.description_intercept_message_header).to eq('Sending a set')
    end
  end

  describe '#description_intercept_message' do
    it 'returns the raw message from the intercept' do
      meta = { 'description_intercept' => { 'message' => 'Sets should be classified...' } }
      result = described_class.new([], meta)
      expect(result.description_intercept_message).to eq('Sets should be classified...')
    end
  end

  describe 'self text description preference' do
    let(:self_text) { 'Horses: pure-bred breeding animals' }
    let(:attrs) { commodity_attrs('description' => 'Pure-bred breeding animals', 'self_text' => self_text) }

    it 'keeps the backend description by default even without metadata' do
      result = described_class.new([attrs], nil)

      expect(result.all.first.description).to eq('Pure-bred breeding animals')
    end

    it 'keeps the backend description when interactive metadata is present' do
      result = described_class.new([attrs], { 'interactive_search' => { 'query' => 'horses' } })

      expect(result.all.first.description).to eq('Pure-bred breeding animals')
    end

    it 'keeps the backend description when metadata lacks interactive data' do
      result = described_class.new([attrs], { 'search_failures' => [] })

      expect(result.all.first.description).to eq('Pure-bred breeding animals')
    end

    context 'when built with prefer_self_text: true' do
      subject(:result) { described_class.new([attrs], nil, prefer_self_text: true) }

      it 'uses the formatted self text as the description' do
        expect(result.all.first.description).to eq(self_text)
      end

      it 'marks the formatted self text as html safe' do
        expect(result.all.first.description).to be_html_safe
      end

      it 'falls back to the backend description when self text is blank' do
        attrs = commodity_attrs('description' => 'Pure-bred breeding animals', 'self_text' => '')
        result = described_class.new([attrs], nil, prefer_self_text: true)

        expect(result.all.first.description).to eq('Pure-bred breeding animals')
      end

      it 'sanitises unsafe markup from the self text', :aggregate_failures do
        attrs = commodity_attrs('self_text' => 'Horses<br><script>alert(1)</script> ponies')
        result = described_class.new([attrs], nil, prefer_self_text: true)
        description = result.all.first.description

        expect(description).to include('Horses<br>')
        expect(description).not_to include('<script')
      end

      it 'keeps permitted inline markup from the self text' do
        attrs = commodity_attrs('self_text' => 'Horses<sub>1</sub> and<sup>2</sup> ponies<br>foals')
        result = described_class.new([attrs], nil, prefer_self_text: true)

        expect(result.all.first.description).to eq('Horses<sub>1</sub> and<sup>2</sup> ponies<br>foals')
      end

      it 'applies to every result class' do
        result = described_class.new(
          [
            heading_attrs('description' => 'Live horses', 'self_text' => 'Horses: live animals'),
            chapter_attrs('description' => 'Live animals', 'self_text' => 'Animals: live'),
          ],
          nil,
          prefer_self_text: true,
        )

        expect(result.all.map(&:description)).to eq(['Horses: live animals', 'Animals: live'])
      end
    end
  end

  describe '#gn_matches_without_duplicates_by_chapter with linked ancestors' do
    def linked_chapter_hash(overrides = {})
      {
        'goods_nomenclature_item_id' => '0100000000',
        'producline_suffix' => GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
        'goods_nomenclature_class' => 'Chapter',
        'description' => 'Live animals',
        'formatted_description' => 'Live animals',
      }.merge(overrides)
    end

    def linked_heading_hash(overrides = {})
      {
        'goods_nomenclature_item_id' => '0101000000',
        'producline_suffix' => GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
        'goods_nomenclature_class' => 'Heading',
        'description' => 'Live horses',
        'formatted_description' => 'Live horses',
        'chapter' => linked_chapter_hash,
      }.merge(overrides)
    end

    it 'uses full linked ancestor descriptions even when primary self text is absent', :aggregate_failures do
      heading = linked_heading_hash(
        'self_text' => 'Horses: live animals',
        'chapter' => linked_chapter_hash('self_text' => 'Animals: live'),
      )
      result = described_class.new([
        commodity_attrs('heading' => heading),
        subheading_attrs('heading' => heading),
      ], nil, prefer_self_text: true)

      expect(result.all.map { |row| row.heading.description }).to eq(['Horses: live animals'] * 2)
      expect(result.all.map { |row| row.heading.chapter.description }).to eq(['Animals: live'] * 2)
      expect(result.all.first.heading.heading).to equal(result.all.first.heading)
    end

    it 'keeps short linked ancestor descriptions without the preference', :aggregate_failures do
      heading = linked_heading_hash(
        'self_text' => 'Horses: live animals',
        'chapter' => linked_chapter_hash('self_text' => 'Animals: live'),
      )
      result = described_class.new([commodity_attrs('heading' => heading)])

      expect(result.all.first.heading.description).to eq('Live horses')
      expect(result.all.first.heading.chapter.description).to eq('Live animals')
    end

    it 'groups headings and chapters under each chapter, sorted by chapter code', :aggregate_failures do
      result = described_class.new([
        chapter_attrs('goods_nomenclature_item_id' => '0200000000', 'description' => 'Meat', 'formatted_description' => 'Meat'),
        heading_attrs(
          'goods_nomenclature_item_id' => '0201000000',
          'description' => 'Meat of bovine animals',
          'chapter' => linked_chapter_hash('goods_nomenclature_item_id' => '0200000000', 'description' => 'Meat', 'formatted_description' => 'Meat'),
        ),
        heading_attrs('chapter' => linked_chapter_hash),
      ])

      grouped = result.gn_matches_without_duplicates_by_chapter

      expect(grouped.map(&:first)).to eq(%w[01 02])
      expect(grouped[0][1][1].map(&:short_code)).to eq(%w[0101])
      expect(grouped[1][1][1].map(&:short_code)).to eq(%w[0201])
    end

    it 'groups sibling ancestors for commodities and subheadings', :aggregate_failures do
      chapter = linked_chapter_hash('self_text' => 'Animals: live')
      result = described_class.new([
        heading_attrs,
        commodity_attrs('heading' => linked_heading_hash.except('chapter'), 'chapter' => chapter),
        subheading_attrs(
          'heading' => linked_heading_hash('goods_nomenclature_item_id' => '0102000000').except('chapter'),
          'chapter' => chapter,
        ),
      ], nil, prefer_self_text: true)

      grouped = result.gn_matches_without_duplicates_by_chapter

      expect(grouped.map(&:first)).to eq(%w[01])
      expect(grouped.first[1][0].description).to eq('Animals: live')
      expect(grouped.first[1][1].map(&:short_code)).to eq(%w[0101 0102])
    end

    it 'deduplicates headings shared by multiple result rows', :aggregate_failures do
      result = described_class.new([
        commodity_attrs('heading' => linked_heading_hash),
        subheading_attrs('heading' => linked_heading_hash),
        heading_attrs('chapter' => linked_chapter_hash),
      ])

      grouped = result.gn_matches_without_duplicates_by_chapter

      expect(grouped.size).to eq(1)
      expect(grouped[0][1][1].map(&:goods_nomenclature_item_id)).to eq(%w[0101000000])
    end

    it 'deduplicates chapters from both direct results and heading ancestors', :aggregate_failures do
      result = described_class.new([
        chapter_attrs,
        heading_attrs('chapter' => linked_chapter_hash),
      ])

      grouped = result.gn_matches_without_duplicates_by_chapter

      expect(grouped.size).to eq(1)
      expect(grouped[0][1][0].goods_nomenclature_item_id).to eq('0100000000')
    end

    it 'does not raise when a heading has no resolvable chapter ancestor' do
      result = described_class.new([
        heading_attrs,
        heading_attrs('goods_nomenclature_item_id' => '0102000000'),
      ])

      expect(result.gn_matches_without_duplicates_by_chapter).to eq([])
    end
  end
end
