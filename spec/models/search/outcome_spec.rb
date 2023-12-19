RSpec.describe Search::Outcome do
  describe '#commodities' do
    subject(:commodities) { outcome.commodities }

    let(:outcome) { build(:search_outcome, :fuzzy_match) }

    it { expect(commodities.count).to eq(outcome.reference_match.commodities.count + outcome.goods_nomenclature_match.commodities.count) }
    it { is_expected.to all(be_a(Commodity)) }
  end
end
