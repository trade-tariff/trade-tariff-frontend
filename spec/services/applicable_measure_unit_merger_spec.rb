RSpec.describe ApplicableMeasureUnitMerger, :user_session do
  subject(:service) { described_class.new }

  include_context 'with a fake commodity'

  let(:uk_commodity) { build(:commodity, :with_uk_complex_measure_units) }
  let(:xi_commodity) { build(:commodity, :with_xi_simple_measure_units) }

  describe '#call' do
    context 'when on the deltas route' do
      let(:user_session) { build(:user_session, :deltas_applicable) }

      let(:expected_units) do
        {
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '% vol',
            'unit_question' => 'What is the alcohol percentage (%) of the goods you are importing?',
            'unit_hint' => 'Enter the alcohol by volume (ABV) percentage',
            'unit' => 'percent',
          },
          'KGM' => {
            'measurement_unit_code' => 'KGM',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => 'kg',
            'unit_question' => 'What is the weight of the goods that you will be importing?',
            'unit_hint' => 'Enter the value in kilograms',
            'unit' => 'kilograms',
            'multiplier' => nil,
            'coerced_measurement_unit_code' => nil,
          },
          'RET' => {
            'measurement_unit_code' => 'RET',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => 'GBP',
            'unit_question' => 'What is the retail price of the goods you will be importing?',
            'unit_hint' => 'Enter the value in pounds',
            'unit' => '£',
          },
          'MIL' => {
            'measurement_unit_code' => 'MIL',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '1,000 p/st',
            'unit_question' => 'How many items will you be importing?',
            'unit_hint' => 'Enter the value in thousands of items',
            'unit' => 'x 1,000 items',
          },
        }
      end

      it 'fetches the xi commodity' do
        service.call

        expect(commodity_context_service).to have_received(:call).with(
          'xi',
          anything,
          anything,
        )
      end

      it 'fetches the uk commodity' do
        service.call

        expect(commodity_context_service).to have_received(:call).with(
          'uk',
          anything,
          anything,
        )
      end

      it { expect(service.call).to eq(expected_units) }
    end

    context 'when on an xi route' do
      let(:user_session) { build(:user_session, commodity_source: 'xi') }

      let(:expected_units) do
        {
          'KGM' => { # XI filtered commodity measurement unit
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => '100 kg',
            'unit_question' => 'What is the weight of the goods you will be importing?',
            'unit_hint' => 'Enter the value in kilogrammes',
            'unit' => 'kilogrammes',
            'multiplier' => '0.01',
            'coerced_measurement_unit_code' => 'KGM',
          },
          'RET' => { # UK filtered commodity excise measurement unit
            'measurement_unit_code' => 'RET',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => 'GBP',
            'unit_question' => 'What is the retail price of the goods you will be importing?',
            'unit_hint' => 'Enter the value in pounds',
            'unit' => '£',
          },
          'MIL' => { # UK filtered commodity excise measurement unit
            'measurement_unit_code' => 'MIL',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '1,000 p/st',
            'unit_question' => 'How many items will you be importing?',
            'unit_hint' => 'Enter the value in thousands of items',
            'unit' => 'x 1,000 items',
          },
        }
      end

      it 'fetches the xi commodity' do
        service.call

        expect(commodity_context_service).to have_received(:call).with(
          'xi',
          anything,
          anything,
        )
      end

      it 'fetches the uk commodity' do
        service.call

        expect(commodity_context_service).to have_received(:call).with(
          'uk',
          anything,
          anything,
        )
      end

      it { expect(service.call).to eq(expected_units) }
    end

    context 'when on a uk route' do
      let(:user_session) { build(:user_session, commodity_source: 'uk') }

      let(:expected_units) do
        {
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '% vol',
            'unit_question' => 'What is the alcohol percentage (%) of the goods you are importing?',
            'unit_hint' => 'Enter the alcohol by volume (ABV) percentage',
            'unit' => 'percent',
          },
          'KGM' => {
            'measurement_unit_code' => 'KGM',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => 'kg',
            'unit_question' => 'What is the weight of the goods that you will be importing?',
            'unit_hint' => 'Enter the value in kilograms',
            'unit' => 'kilograms',
            'multiplier' => nil,
            'coerced_measurement_unit_code' => nil,
          },
          'RET' => {
            'measurement_unit_code' => 'RET',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => 'GBP',
            'unit_question' => 'What is the retail price of the goods you will be importing?',
            'unit_hint' => 'Enter the value in pounds',
            'unit' => '£',
          },
          'MIL' => {
            'measurement_unit_code' => 'MIL',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '1,000 p/st',
            'unit_question' => 'How many items will you be importing?',
            'unit_hint' => 'Enter the value in thousands of items',
            'unit' => 'x 1,000 items',
          },
        }
      end

      it 'does not fetch the xi commodity' do
        service.call

        expect(commodity_context_service).not_to have_received(:call).with(
          'xi',
          anything,
          anything,
        )
      end

      it 'fetches the uk commodity' do
        service.call

        expect(commodity_context_service).to have_received(:call).with(
          'uk',
          anything,
          anything,
        )
      end

      it { expect(service.call).to eq(expected_units) }
    end

    context 'when dedupe is not set on the constructor' do
      subject(:result) do
        described_class.new.call.transform_values do |value|
          value.slice('measurement_unit_code', 'measurement_unit_qualifier_code', 'coerced_measurement_unit_code')
        end
      end

      let(:user_session) { build(:user_session, :deltas_applicable) }

      let(:expected_units) do
        {
          # 'DTN' => { # Removed unit - coerced
          #   'measurement_unit_code' => 'DTN',
          #   'measurement_unit_qualifier_code' => nil,
          #   'coerced_measurement_unit_code' => 'KGM',
          # },
          'RET' => {
            'measurement_unit_code' => 'RET',
            'measurement_unit_qualifier_code' => '',
          },
          'MIL' => {
            'measurement_unit_code' => 'MIL',
            'measurement_unit_qualifier_code' => '',
          },
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => '',
          },
          # 'DTNR' => { # Removed unit - coerced
          #   'measurement_unit_code' => 'DTN',
          #   'measurement_unit_qualifier_code' => 'R',
          #   'coerced_measurement_unit_code' => 'KGM',
          # },
          'KGM' => { # Last unit wins - uncoerced
            'measurement_unit_code' => 'KGM',
            'measurement_unit_qualifier_code' => nil,
            'coerced_measurement_unit_code' => nil,
          },
        }
      end

      it 'dedupes the measure units' do
        expect(result).to eq(expected_units)
      end
    end

    context 'when dedupe is set to true on the constructor' do
      subject(:result) do
        described_class.new(dedupe: true).call.transform_values do |value|
          value.slice('measurement_unit_code', 'measurement_unit_qualifier_code', 'coerced_measurement_unit_code')
        end
      end

      let(:user_session) { build(:user_session, :deltas_applicable) }

      let(:expected_units) do
        {
          # 'DTN' => { # Removed unit - coerced
          #   'measurement_unit_code' => 'DTN',
          #   'measurement_unit_qualifier_code' => nil,
          #   'coerced_measurement_unit_code' => 'KGM',
          # },
          'RET' => {
            'measurement_unit_code' => 'RET',
            'measurement_unit_qualifier_code' => '',
          },
          'MIL' => {
            'measurement_unit_code' => 'MIL',
            'measurement_unit_qualifier_code' => '',
          },
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => '',
          },
          # 'DTNR' => { # Removed unit - coerced
          #   'measurement_unit_code' => 'DTN',
          #   'measurement_unit_qualifier_code' => 'R',
          #   'coerced_measurement_unit_code' => 'KGM',
          # },
          'KGM' => { # Last unit wins - uncoerced
            'measurement_unit_code' => 'KGM',
            'measurement_unit_qualifier_code' => nil,
            'coerced_measurement_unit_code' => nil,
          },
        }
      end

      it 'dedupes the measure units' do
        expect(result).to eq(expected_units)
      end
    end

    context 'when dedupe is set to false on the constructor' do
      subject(:result) do
        described_class.new(dedupe: false).call.transform_values do |value|
          value.slice('measurement_unit_code', 'measurement_unit_qualifier_code', 'coerced_measurement_unit_code')
        end
      end

      let(:user_session) { build(:user_session, :deltas_applicable) }

      let(:expected_units) do
        {
          'DTN' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => nil,
            'coerced_measurement_unit_code' => 'KGM',
          },
          'RET' => {
            'measurement_unit_code' => 'RET',
            'measurement_unit_qualifier_code' => '',
          },
          'MIL' => {
            'measurement_unit_code' => 'MIL',
            'measurement_unit_qualifier_code' => '',
          },
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => '',
          },
          'DTNR' => { # Unit not removed
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => 'R',
            'coerced_measurement_unit_code' => 'KGM',
          },
          'KGM' => { # Unit not removed
            'measurement_unit_code' => 'KGM',
            'measurement_unit_qualifier_code' => nil,
            'coerced_measurement_unit_code' => nil,
          },
        }
      end

      it 'does not dedupe the measure units' do
        expect(result).to eq(expected_units)
      end
    end
  end
end
