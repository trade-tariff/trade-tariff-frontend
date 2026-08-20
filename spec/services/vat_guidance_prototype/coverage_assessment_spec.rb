RSpec.describe VatGuidancePrototype::CoverageAssessment do
  subject(:assessment) do
    described_class.new(
      commodity_code:,
      vat_options:,
      as_of: Date.new(2026, 7, 21),
    ).call
  end

  let(:commodity_code) { '1516209821' }
  let(:vat_options) do
    {
      'VAT' => 'Value added tax (20.0%)',
      'VATZ' => 'VAT zero rate (0.0%)',
    }
  end

  it 'offers an approved journey for a mapped multi-option commodity', :aggregate_failures do
    expect(assessment).to be_guided
    expect(assessment.journey.id).to eq('vegetable_oil_blend')
    expect(assessment.vat_options).to eq(vat_options)
  end

  {
    '0106410000' => 'bees',
    '4903000000' => 'childrens_picture_books',
    '0602903000' => 'vegetable_and_strawberry_plants',
  }.each do |code, journey_id|
    context "with reviewed commodity #{code}" do
      let(:commodity_code) { code }

      it "offers the #{journey_id} journey", :aggregate_failures do
        expect(assessment).to be_guided
        expect(assessment.journey.id).to eq(journey_id)
        expect(assessment.journey).to be_reviewed
        expect(assessment.vat_options).to eq(vat_options)
      end
    end
  end

  context 'with an unmapped multi-option commodity' do
    let(:commodity_code) { '9999999999' }

    it 'covers it with a generic journey using every live option', :aggregate_failures do
      expect(assessment).to be_guided
      expect(assessment.journey).to be_generic
      expect(assessment.journey.commodity_code).to eq('9999999999')
      expect(assessment.vat_options.keys).to contain_exactly('VAT', 'VATZ')
      expect(assessment.journey.allowed_outcomes).to contain_exactly('VAT', 'VATZ')
    end
  end

  context 'with only one live VAT option' do
    let(:vat_options) { { 'VAT' => 'Value added tax (20.0%)' } }

    it { is_expected.to be_not_eligible }
  end
end
