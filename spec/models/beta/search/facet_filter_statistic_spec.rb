require 'spec_helper'

RSpec.describe Beta::Search::FacetFilterStatistic do
  subject(:facet_filter_statistic) { build(:facet_filter_statistic) }

  it { expect(described_class.relationships).to eq(%i[facet_classification_statistics]) }

  it {
    expect(facet_filter_statistic).to have_attributes(facet_filter: 'material',
                                                      facet_count: 10,
                                                      display_name: 'Material',
                                                      question: 'What material?')
  }

  describe '#facet' do
    subject(:facet) { build(:facet_filter_statistic, facet_filter: 'filter_material').facet }

    it { is_expected.to eq('material') }
  end

  describe '#find_classification' do
    context 'when there is a matching classification' do
      subject(:find_classification) { build(:facet_filter_statistic).find_classification('leather') }

      it { is_expected.to be_a(Beta::Search::FacetClassificationStatistic) }
    end

    context 'when there is no matching classification' do
      subject(:find_classification) { build(:facet_filter_statistic).find_classification('sausage') }

      it { is_expected.to be_nil }
    end
  end
end
