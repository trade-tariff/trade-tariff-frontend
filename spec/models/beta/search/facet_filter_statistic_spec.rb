require 'spec_helper'

RSpec.describe Beta::Search::FacetFilterStatistic do
  subject(:facet_filter_statistic) { build(:facet_filter_statistic) }

  it { expect(described_class.relationships).to eq(%i[facet_classification_statistics]) }

  it {
    expect(facet_filter_statistic).to have_attributes(facet_filter: 'animal_type',
                                                      facet_count: 10,
                                                      display_name: 'Animal Type',
                                                      question: 'What animal type?')
  }
end
