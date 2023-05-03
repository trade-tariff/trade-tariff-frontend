require 'spec_helper'

RSpec.describe SearchSuggestion do
  subject { build(:search_suggestion) }

  it { is_expected.to have_attributes(score: 0.1124, query: 'test', value: 'test', suggestion_type: 'search_reference', priority: 1) }

  describe '#formatted_suggestion_type' do
    shared_examples_for 'a formatted suggestion type' do |suggestion_type, value, goods_nomenclature_class, formatted_suggestion_type|
      subject(:suggestion_type) do
        build(
          :search_suggestion,
          suggestion_type:,
          value:,
          goods_nomenclature_class:,
        ).formatted_suggestion_type
      end

      it { is_expected.to eq(formatted_suggestion_type) }
    end

    it_behaves_like 'a formatted suggestion type', 'search_reference', nil, 'Heading', ''
    it_behaves_like 'a formatted suggestion type', 'goods_nomenclature', '12', 'Chapter', 'Chapter'
    it_behaves_like 'a formatted suggestion type', 'goods_nomenclature', '1234', 'Heading', 'Heading'
    it_behaves_like 'a formatted suggestion type', 'goods_nomenclature', '123456', 'Subheading', 'Subheading'
    it_behaves_like 'a formatted suggestion type', 'goods_nomenclature', '1234567890', 'Commodity', 'Commodity'
    it_behaves_like 'a formatted suggestion type', 'full_chemical_cas', nil, 'Heading', 'Chemical'
    it_behaves_like 'a formatted suggestion type', 'full_chemical_cus', nil, 'Heading', 'Chemical'
    it_behaves_like 'a formatted suggestion type', 'full_chemical_name', nil, 'Heading', 'Chemical'
    it_behaves_like 'a formatted suggestion type', 'something_else', nil, 'Heading', 'Something else'
    it_behaves_like 'a formatted suggestion type', nil, nil, 'Heading', ''
  end
end
