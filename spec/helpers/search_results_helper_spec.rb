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
end
