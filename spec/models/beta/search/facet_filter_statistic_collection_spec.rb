require 'spec_helper'

RSpec.describe Beta::Search::FacetFilterStatisticCollection do
  describe '#applicable' do
    subject(:applicable) { described_class.new(facet_filter_statistics).applicable }

    context 'when there are facet filter statistics' do
      let(:facet_filter_statistics) do
        casted_by = build(:search_result, total_results: 100)

        [
          build(:facet_filter_statistic, facet_count: 4, casted_by:), # Below threshold
          build(:facet_filter_statistic, facet_count: 5, casted_by:), # On threshold
          build(:facet_filter_statistic, facet_count: 6, casted_by:), # Above threshold
        ]
      end

      it { is_expected.to eq([facet_filter_statistics.last]) }
      it { is_expected.to be_a(described_class) }
    end

    context 'when there are no facet filter statistics' do
      let(:facet_filter_statistics) { [] }

      it { is_expected.to be_empty }
      it { is_expected.to be_a(described_class) }
    end
  end
end
