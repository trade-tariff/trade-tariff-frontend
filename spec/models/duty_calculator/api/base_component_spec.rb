RSpec.describe DutyCalculator::Api::BaseComponent do
  subject(:component) do
    described_class.new(
      'duty_expression_id' => '01',
      'duty_amount' => 10.0,
      'monetary_unit_code' => nil,
      'monetary_unit_abbreviation' => nil,
      'measurement_unit_code' => nil,
      'duty_expression_description' => '% or amount',
      'duty_expression_abbreviation' => '%',
      'measurement_unit_qualifier_code' => nil,
    )
  end

  it_behaves_like 'a resource that has attributes',
                  id: 'flibble',
                  duty_expression_id: '01',
                  duty_amount: 0.0,
                  monetary_unit_code: nil,
                  monetary_unit_abbreviation: nil,
                  measurement_unit_code: nil,
                  duty_expression_description: '% or amount',
                  duty_expression_abbreviation: '%',
                  measurement_unit_qualifier_code: nil

  it_behaves_like 'a resource that has an enum', :monetary_unit_code, {
    euros: %w[EUR],
    pounds: %w[GBP],
  }

  it_behaves_like 'a resource that has an enum', :measurement_unit_code, {
    retail_price: %w[RET],
  }

  it_behaves_like 'a resource that has an enum', :duty_expression_id, {
    amount_or_percentage: %w[01 04 19 20],
  }

  describe '#ad_valorem?' do
    context 'when it is ad_valorem' do
      it 'returns true' do
        expect(component).to be_ad_valorem
      end
    end

    context 'when it is not ad_valorem' do
      subject(:component) do
        described_class.new(
          'duty_expression_id' => '01',
          'duty_amount' => 10.0,
          'monetary_unit_code' => 'GBP',
          'monetary_unit_abbreviation' => nil,
          'measurement_unit_code' => 'DTN',
          'duty_expression_description' => '% or amount',
          'duty_expression_abbreviation' => '%',
          'measurement_unit_qualifier_code' => nil,
        )
      end

      it 'returns false' do
        expect(component).not_to be_ad_valorem
      end
    end
  end

  describe '#specific_duty?' do
    subject(:component) { described_class.new(measurement_unit_code:) }

    context 'when measurement_unit_code is present' do
      let(:measurement_unit_code) { 'DTN' }

      it { expect(component).to be_specific_duty }
    end

    context 'when measurement_unit_code is not present' do
      let(:measurement_unit_code) { nil }

      it { expect(component).not_to be_specific_duty }
    end
  end

  describe '#no_specific_duty?' do
    subject(:component) { described_class.new(measurement_unit_code:) }

    context 'when measurement_unit_code is present' do
      let(:measurement_unit_code) { 'DTN' }

      it { expect(component).not_to be_no_specific_duty }
    end

    context 'when measurement_unit_code is not present' do
      let(:measurement_unit_code) { nil }

      it { expect(component).to be_no_specific_duty }
    end
  end

  describe '#alcohol_volume?' do
    subject(:component) do
      described_class.new(
        'measurement_unit_code' => measurement_unit_code,
        'measurement_unit_qualifier_code' => measurement_unit_qualifier_code,
      )
    end

    context 'when the unit is an alcohol volume unit' do
      let(:measurement_unit_code) { 'ASV' }
      let(:measurement_unit_qualifier_code) { 'X' }

      it { expect(component).to be_alcohol_volume }
    end

    context 'when the unit is not an alcohol volume unit' do
      let(:measurement_unit_code) { 'ASV' }
      let(:measurement_unit_qualifier_code) { '' }

      it { expect(component).not_to be_alcohol_volume }
    end
  end

  describe '#sucrose?' do
    subject(:component) do
      described_class.new(
        'measurement_unit_code' => measurement_unit_code,
        'measurement_unit_qualifier_code' => measurement_unit_qualifier_code,
      )
    end

    context 'when the unit is sucrose' do
      let(:measurement_unit_code) { 'DTN' }
      let(:measurement_unit_qualifier_code) { 'Z' }

      it { is_expected.to be_sucrose }
    end

    context 'when the unit is `not` sucrose' do
      let(:measurement_unit_code) { 'DTN' }
      let(:measurement_unit_qualifier_code) { '' }

      it { is_expected.not_to be_sucrose }
    end
  end

  describe '#conjunction_operator?' do
    subject(:component) do
      described_class.new(
        'duty_expression_id' => '01',
        'duty_amount' => 10.0,
        'monetary_unit_code' => nil,
        'monetary_unit_abbreviation' => nil,
        'measurement_unit_code' => nil,
        'duty_expression_description' => '% or amount',
        'duty_expression_abbreviation' => duty_expression_abbreviation,
        'measurement_unit_qualifier_code' => nil,
      )
    end

    let(:duty_expression_abbreviation) { '%' }

    context 'when it is a conjunction operator' do
      let(:duty_expression_abbreviation) { 'MAX' }

      it 'returns true' do
        expect(component).to be_conjunction_operator
      end
    end

    context 'when it is not a conjunction operator' do
      it 'returns false' do
        expect(component).not_to be_conjunction_operator
      end
    end
  end

  describe '#operator' do
    it { expect(component.operator).to eq('%') }
  end

  describe 'unit' do
    context 'when the component has unit attributes' do
      subject(:component) { described_class.new(attributes_for(:duty_calculator_measure_component, :with_measure_units)) }

      it { expect(component.unit).to eq('DTN') }
    end

    context 'when the component has no unit attributes' do
      subject(:component) { described_class.new(attributes_for(:duty_calculator_measure_component)) }

      it { expect(component.unit).to be_nil }
    end
  end
end
