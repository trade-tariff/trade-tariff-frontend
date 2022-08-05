require 'spec_helper'

RSpec.describe Beta::Search::FacetClassificationStatistic do
  subject(:facet_classification_statistic) { build(:facet_classification_statistic) }

  it {
    expect(facet_classification_statistic).to have_attributes(facet: 'animal_type',
                                                              count: 7,
                                                              classification: 'swine')
  }

  describe '#filter' do
    subject(:filter) { build(:facet_classification_statistic).filter }

    it { is_expected.to eq(animal_type: 'swine') }
  end
end
