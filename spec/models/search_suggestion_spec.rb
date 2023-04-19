require 'spec_helper'

RSpec.describe SearchSuggestion do
  subject { build(:search_suggestion) }

  it { is_expected.to have_attributes(score: 0.1124, query: 'test', value: 'test', suggestion_type: 'search_reference', priority: 1) }

  describe '#formatted_suggestion_type' do
    shared_examples_for 'a formatted suggestion type' do |suggestion_type, value, formatted_suggestion_type|
      subject(:suggestion_type) do
        build(
          :search_suggestion,
          suggestion_type:,
          value:,
        ).formatted_suggestion_type
      end

      it { is_expected.to eq(formatted_suggestion_type) }
    end

    it_behaves_like 'a formatted suggestion type', 'search_reference', nil, ''
    it_behaves_like 'a formatted suggestion type', 'goods_nomenclature', '12', 'Chapter'
    it_behaves_like 'a formatted suggestion type', 'goods_nomenclature', '1234', 'Heading'
    it_behaves_like 'a formatted suggestion type', 'goods_nomenclature', '1234567890', 'Commodity'
    it_behaves_like 'a formatted suggestion type', 'full_chemical_cas', nil, 'Chemical'
    it_behaves_like 'a formatted suggestion type', 'full_chemical_cus', nil, 'Chemical'
    it_behaves_like 'a formatted suggestion type', 'full_chemical_name', nil, 'Chemical'
    it_behaves_like 'a formatted suggestion type', 'something_else', nil, 'Something else'
    it_behaves_like 'a formatted suggestion type', nil, nil, ''
  end
end
