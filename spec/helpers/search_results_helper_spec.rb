require 'spec_helper'

RSpec.describe SearchResultsHelper, type: :helper do
  describe '#filtered_link_for' do
    subject { helper.filtered_link_for(facet_classification_statistic) }

    before do
      assign(:filters, 'material' => 'leather')
      assign(:query, 'clothing')
      assign(
        :url_options,
        year: 'foo',
        month: 'bar',
        day: 'baz',
        country: 'IT',
      )
    end

    let(:facet_classification_statistic) { build(:facet_classification_statistic, :garment_type) }

    let(:expected_link) { '<a href="/search?filter%5Bgarment_type%5D=trousers+and+shorts&amp;filter%5Bmaterial%5D=leather&amp;q=clothing">Trousers and shorts</a> (7)' }

    it { is_expected.to eq(expected_link) }
  end

  describe '#disapply_filter_link_for' do
    subject { helper.disapply_filter_link_for(facet_classification_statistic) }

    before do
      assign(:filters, 'material' => 'leather')
      assign(:query, 'clothing')
      assign(
        :url_options,
        year: 'foo',
        month: 'bar',
        day: 'baz',
        country: 'IT',
      )
    end

    let(:facet_classification_statistic) { build(:facet_classification_statistic, :material) }

    let(:expected_link) { '<a class="facet-classifications-tag" href="/search?q=clothing">[x] Leather</a>' }

    it { is_expected.to eq(expected_link) }
  end

  describe '#applied_filter_classifications' do
    subject { helper.applied_filter_classifications.map(&:classification) }

    before do
      assign(:filters, 'material' => 'leather')
      assign(:search_result, search_result)
    end

    context 'when there are facet filter classifications' do
      let(:search_result) { build(:search_result) }
      let(:expected_classifications) { %w[leather] }

      it { is_expected.to eq(expected_classifications) }
    end

    context 'when there are no facet filter classifications' do
      let(:search_result) { build(:search_result, :no_facets) }

      it { is_expected.to eq([]) }
    end
  end

  describe '#ancestor_links' do
    subject(:ancestor_links) { helper.ancestor_links(hit) }

    context 'when the hit has ancestors' do
      let(:hit) { build(:commodity, :with_ancestors) }

      it 'returns heading and subheading links' do
        expect(ancestor_links).to eq(
          [
            '<a href="/headings/0101">Live horses, asses, mules and hinnies </a>',
            '<a href="/subheadings/0101100000-10">Horses</a>',
          ],
        )
      end
    end

    context 'when the hit has no ancestors' do
      let(:hit) { build(:commodity, :without_ancestors) }

      it { is_expected.to eq([]) }
    end
  end

  describe '#uncorrected_search_link_for' do
    subject(:uncorrected_search_link_for) { helper.uncorrected_search_link_for(original_search_query) }

    let(:original_search_query) { 'halbiut' }

    before do
      assign(:filters, 'material' => 'leather', 'heading' => '0101')
      assign(:query, 'halbiut')
    end

    it 'returns the original search query with a spell query param' do
      expect(uncorrected_search_link_for).to eq(
        '<a href="/search?filter%5Bheading%5D=0101&amp;filter%5Bmaterial%5D=leather&amp;q=halbiut&amp;spell=0">halbiut</a>',
      )
    end
  end
end
