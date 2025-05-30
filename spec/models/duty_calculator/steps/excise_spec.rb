RSpec.describe DutyCalculator::Steps::Excise, :step, :user_session do
  subject(:step) { build(:duty_calculator_excise) }

  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }
  let(:filtered_commodity) { instance_double(DutyCalculator::Api::Commodity) }
  let(:applicable_vat_options) { {} }

  let(:applicable_additional_codes) do
    {
      '306' => {
        'measure_type_description' => 'Excises',
        'heading' => nil,
        'additional_codes' => [
          {
            'code' => 'X520',
            'overlay' => 'Light oil: unrebated (unmarked) – other unrebated light oil',
            'hint' => '',
            'measure_sid' => -485_461,
          },
          {
            'code' => 'X522',
            'overlay' => 'Light oil: rebated – unleaded petrol',
            'hint' => '',
            'measure_sid' => -485_453,
          },
          {
            'code' => 'X541',
            'overlay' => 'Heavy oil: unrebated (unmarked, including Diesel Engine Road Vehicle (DERV) or road fuel extender and unmarked kerosene or unmarked gas oil for which no marking waiver has been granted)',
            'hint' => '',
            'measure_sid' => -485_455,
          },
          {
            'code' => 'X542',
            'overlay' => 'Heavy oil: kerosene to be used as motor fuel off road or in an excepted vehicle',
            'hint' => '',
            'measure_sid' => -485_456,
          },
          {
            'code' => 'X551',
            'overlay' => 'Heavy oil: kerosene (marked or unmarked under marking waiver, including heavy oil aviation turbine fuel) to be used other than as motor fuel off-road or in an excepted vehicle',
            'hint' => '',
            'measure_sid' => -485_457,
          },
          {
            'code' => 'X556',
            'overlay' => 'Heavy oil: gas oil (marked or unmarked under marking waiver)',
            'hint' => '',
            'measure_sid' => -485_458,
          },
          {
            'code' => 'X561',
            'overlay' => 'Heavy oil: fuel oil (unmarked)',
            'hint' => '',
            'measure_sid' => -485_459,
          },
          {
            'code' => 'X570',
            'overlay' => 'Heavy oil: other (unmarked)',
            'hint' => '',
            'measure_sid' => -485_460,
          },
          {
            'code' => 'X441',
            'overlay' => 'Heavy oil: fuel oil (unmarked)',
            'hint' => '',
            'measure_sid' => -485_461,
          },
        ],
      },
    }
  end

  before do
    allow(DutyCalculator::Api::Commodity).to receive(:build).and_return(filtered_commodity)
    allow(filtered_commodity).to receive_messages(applicable_additional_codes:, applicable_vat_options:)
  end

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it { expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(%w[]) }
  end

  describe '#validations' do
    context 'when measure_type_id is missing' do
      subject(:step) do
        build(
          :duty_calculator_excise,
          user_session:,
          measure_type_id: nil,
        )
      end

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:measure_type_id].to_a).to eq(
          ['Enter a valid measure type id'],
        )
      end
    end

    context 'when the additional_code is not present' do
      subject(:step) do
        build(
          :duty_calculator_excise,
          user_session:,
          additional_code: nil,
        )
      end

      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:additional_code].to_a).to eq(['Select an excise class'])
      end
    end
  end

  describe '#save!' do
    it 'saves the additional codes on to the session' do
      expect { step.save! }.to change(user_session, :excise_additional_code).from({}).to('306' => '444')
    end
  end

  describe '#measure_type_description' do
    it { expect(step.measure_type_description).to eq('excises') }
  end

  describe '#options' do
    let(:expected_options) do
      [
        OpenStruct.new(
          id: '520',
          name: 'Light oil: unrebated (unmarked) – other unrebated light oil (X520)',
          disabled: false,
        ),
        OpenStruct.new(
          id: '522',
          name: 'Light oil: rebated – unleaded petrol (X522)',
          disabled: false,
        ),
        OpenStruct.new(
          id: '541',
          name: 'Heavy oil: unrebated (unmarked, including Diesel Engine Road Vehicle (DERV) or road fuel extender and unmarked kerosene or unmarked gas oil for which no marking waiver has been granted) (X541)',
          disabled: false,
        ),
        OpenStruct.new(
          id: '542',
          name: 'Heavy oil: kerosene to be used as motor fuel off road or in an excepted vehicle (X542)',
          disabled: false,
        ),
        OpenStruct.new(
          id: '551',
          name: 'Heavy oil: kerosene (marked or unmarked under marking waiver, including heavy oil aviation turbine fuel) to be used other than as motor fuel off-road or in an excepted vehicle (X551)',
          disabled: false,
        ),
        OpenStruct.new(
          id: '556',
          name: 'Heavy oil: gas oil (marked or unmarked under marking waiver) (X556)',
          disabled: false,
        ),
        OpenStruct.new(
          id: '561',
          name: 'Heavy oil: fuel oil (unmarked) (X561)',
          disabled: false,
        ),
        OpenStruct.new(
          id: '570',
          name: 'Heavy oil: other (unmarked) (X570)',
          disabled: false,
        ),
        OpenStruct.new(
          id: '441',
          name: 'Heavy oil: fuel oil (unmarked) (X441)',
          disabled: true,
        ),
      ]
    end

    it { expect(step.options).to eq(expected_options) }
    it { expect(step.options.first.name).to be_html_safe }
  end

  describe '#additional_code' do
    context 'when there are attributes being passed in' do
      it 'returns the additional code attribute value on the active model' do
        expect(step.additional_code).to eq('444')
      end
    end

    context 'when there is no additional codes being passed in, but the value is on the session' do
      subject(:step) do
        build(
          :duty_calculator_excise,
          user_session:,
          additional_code: nil,
        )
      end

      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_excise_additional_codes,
          :with_commodity_information,
        )
      end

      it { is_expected.to be_valid }

      it 'returns the value from the session that corresponds to measure type 306' do
        expect(step.additional_code).to eq('444')
      end
    end
  end

  describe '#previous_step_path' do
    let(:applicable_measure_units) { {} }

    before do
      allow(filtered_commodity).to receive(:applicable_measure_units).and_return(applicable_measure_units)
      allow(DutyCalculator::ApplicableMeasureUnitMerger).to receive(:new).and_call_original
    end

    context 'when there is just one measure type id available and measure units are available' do
      let(:applicable_measure_units) do
        {
          'DTN' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '100 kg',
            'unit_question' => 'What is the weight of the goods you will be importing?',
            'unit_hint' => 'Enter the value in decitonnes (100kg)',
            'unit' => 'x 100 kg',
          },
        }
      end

      let(:applicable_additional_codes) do
        {
          '306' => {
            'additional_codes' => [
              { 'code' => 'X411' },
              { 'code' => 'X444' },
            ],
          },
        }
      end

      it { expect(step.previous_step_path).to eq(measure_amount_path) }

      it 'calls the DutyCalculator::ApplicableMeasureUnitMerger service' do
        step.previous_step_path

        expect(DutyCalculator::ApplicableMeasureUnitMerger).to have_received(:new)
      end
    end

    context 'when there is just one measure type id available and no measure units are available' do
      let(:applicable_measure_units) { {} }

      let(:applicable_additional_codes) do
        {
          '306' => {
            'additional_codes' => [
              { 'code' => 'X411' },
              { 'code' => 'X444' },
            ],
          },
        }
      end

      it 'returns the customs_value_path' do
        expect(step.previous_step_path).to eq(customs_value_path)
      end
    end

    context 'when there are non excise measure type ids on the applicable_additional_codes hash' do
      let(:applicable_additional_codes) do
        {
          '306' => {
            'additional_codes' => [
              { 'code' => 'X411' },
              { 'code' => 'X444' },
            ],
          },
          '105' => {
            'additional_codes' => [
              { 'code' => '2600' },
              { 'code' => '2601' },
            ],
          },
        }
      end

      it 'returns additional_codes_path with the previous measure_type_id as argument' do
        expect(step.previous_step_path).to eq(additional_codes_path('105'))
      end
    end
  end

  describe '#next_step_path' do
    context 'when there is just one measure type id on the applicable_additional_codes hash' do
      let(:applicable_additional_codes) do
        {
          '306' => {
            'additional_codes' => [
              { 'code' => 'X411' },
              { 'code' => 'X444' },
            ],
          },
        }
      end

      it 'returns confirm_path' do
        expect(step.next_step_path).to eq(confirm_path)
      end
    end

    context 'when there are less than 2 applicable vat options' do
      let(:applicable_vat_options) do
        {
          'VATZ' => 'flibble',
        }
      end

      it 'returns confirm_path' do
        expect(step.next_step_path).to eq(confirm_path)
      end
    end

    context 'when there are more than 1 applicable vat options' do
      let(:applicable_additional_codes) do
        {
          '306' => {
            'additional_codes' => [
              { 'code' => 'X411' },
              { 'code' => 'X444' },
            ],
          },
        }
      end

      let(:applicable_vat_options) do
        {
          'VATZ' => 'flibble',
          'VATR' => 'foobar',
        }
      end

      it 'returns vat_path' do
        expect(step.next_step_path).to eq(vat_path)
      end
    end
  end

  describe '#small_brewers_relief?' do
    let(:applicable_additional_codes) do
      {
        '306' => { 'additional_codes' => [{ 'code' => additional_code }] },
      }
    end

    context 'when at least one additional code is a small brewers relief code' do
      let(:additional_code) { 'X441' }

      it { is_expected.to be_small_brewers_relief }
    end

    context 'when no additional code is a small brewers relief code' do
      let(:additional_code) { 'X500' }

      it { is_expected.not_to be_small_brewers_relief }
    end
  end
end
