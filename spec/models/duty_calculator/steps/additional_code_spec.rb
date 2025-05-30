RSpec.describe DutyCalculator::Steps::AdditionalCode, :step, :user_session do
  subject(:step) do
    build(
      :duty_calculator_step_additional_code,
      user_session:,
    )
  end

  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }
  let(:commodity_source) { :uk }
  let(:commodity_code) { '7202118000' }

  let(:filtered_commodity) { DutyCalculator::Api::Commodity.build(commodity_source, commodity_code) }

  let(:applicable_vat_options) { {} }

  let(:applicable_additional_codes) do
    {
      '105' => {
        'measure_type_description' => 'third-country duty',
        'heading' => {
          'overlay' => 'Describe your goods in more detail',
          'hint' => 'To trade this commodity, you need to specify an additional 4 digits, known as an additional code',
        },
        'additional_codes' => [
          {
            'code' => '2600',
            'overlay' => 'The product I am importing is COVID-19 critical',
            'hint' => "Read more about the <a target='_blank' href='https://www.gov.uk/government/news/hmg-suspends-import-tariffs-on-covid-19-products-to-fight-virus'>suspension of tariffs on COVID-19 critical goods [opens in a new browser window]</a>",
          },
          {
            'code' => '2601',
            'overlay' => 'The product I am importing is not COVID-19 critical',
            'hint' => '',
          },
        ],
      },

      '552' => {
        'measure_type_description' => 'some type of duty',
        'heading' => {
          'overlay' => 'Describe your goods in more detail',
          'hint' => 'To trade this commodity, you need to specify an additional 4 digits, known as an additional code',
        },
        'additional_codes' => [
          {
            'code' => 'B999',
            'overlay' => 'Other',
            'hint' => '',
            'type' => 'preference',
            'measure_sid' => '20511102',
          },
          {
            'code' => 'B349',
            'overlay' => 'Hunan Hualian China Industry Co., Ltd; Hunan Hualian Ebillion China Industry Co., Ltd; Hunan Liling Hongguanyao China Industry Co., Ltd; Hunan Hualian Yuxiang China Industry Co., Ltd.',
            'hint' => '',
            'type' => 'preference',
            'measure_sid' => '20511103',
          },
        ],
      },
    }
  end

  let(:document_codes) do
    {
      '103' => ['N851', ''],
      '105' => ['C644', 'Y929', ''],
    }
  end

  before do
    allow(DutyCalculator::Api::Commodity).to receive(:build).and_return(filtered_commodity)
    allow(filtered_commodity).to receive_messages(applicable_additional_codes:, applicable_vat_options:)
  end

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(
        %w[document_code excise],
      )
    end
  end

  describe '#validations' do
    context 'when measure_type_id is missing' do
      subject(:step) do
        build(
          :duty_calculator_step_additional_code,
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

    context 'when the additional_code_uk is not present' do
      subject(:step) do
        build(
          :duty_calculator_step_additional_code,
          user_session:,
          additional_code_uk: nil,
        )
      end

      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, :deltas_applicable) }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:additional_code_uk].to_a).to eq(
          ['Specify a valid additional code'],
        )
      end
    end

    context 'when the additional_code_xi is not present' do
      subject(:step) do
        build(
          :duty_calculator_step_additional_code,
          user_session:,
          additional_code_xi: nil,
        )
      end

      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, :deltas_applicable) }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:additional_code_xi].to_a).to eq(
          ['Specify a valid additional code'],
        )
      end
    end
  end

  describe '#save!' do
    it 'saves the additional codes for uk on to the session' do
      expect { step.save! }.to change(user_session, :additional_code_uk).from({}).to('105' => '2300')
    end

    it 'saves the additional codes for xi on to the session' do
      expect { step.save! }.to change(user_session, :additional_code_xi).from({}).to('105' => '2600')
    end
  end

  describe '#measure_type_description' do
    it 'returns the correct measure type description' do
      expect(step.measure_type_description_for(source: 'uk')).to eq('third-country duty')
    end
  end

  describe '#options_for_select' do
    let(:expected_options) do
      [
        OpenStruct.new(
          id: '2600',
          name: '2600 - The product I am importing is COVID-19 critical',
        ),
        OpenStruct.new(
          id: '2601',
          name: '2601 - The product I am importing is not COVID-19 critical',
        ),
      ]
    end

    it 'returns the correct additional code options for the given measure' do
      expect(step.options_for_select_for(source: 'uk')).to eq(expected_options)
    end
  end

  describe '#additional_code_uk' do
    context 'when there are attributes being passed in' do
      it 'returns the additional code attribute value on the active model' do
        expect(step.additional_code_uk).to eq('2300')
      end
    end

    context 'when there is no additional code being passed in, but the value is on the session' do
      subject(:step) do
        build(
          :duty_calculator_step_additional_code,
          user_session:,
          additional_code_uk: nil,
        )
      end

      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_additional_codes,
          :with_commodity_information,
        )
      end

      it { is_expected.to be_valid }

      it 'returns the value from the session that corresponds to measure type 105' do
        expect(step.additional_code_uk).to eq('2340')
      end
    end
  end

  describe '#additional_code_xi' do
    context 'when there are attributes being passed in' do
      it 'returns the additional code attribute value on the active model' do
        expect(step.additional_code_xi).to eq('2600')
      end
    end

    context 'when there is no additional code being passed in, but the value is on the session' do
      subject(:step) do
        build(
          :duty_calculator_step_additional_code,
          user_session:,
          additional_code_xi: nil,
        )
      end

      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_additional_codes,
          :with_commodity_information,
        )
      end

      it { is_expected.to be_valid }

      it 'returns the value from the session that corresponds to measure type 105' do
        expect(step.additional_code_xi).to eq('2340')
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
          '105' => {
            'heading' => {
              'overlay' => 'Describe your goods in more detail',
              'hint' => 'To trade this commodity, you need to specify an additional 4 digits, known as an additional code',
            },
            'additional_codes' => [
              {
                'code' => '2600',
                'overlay' => 'The product I am importing is COVID-19 critical',
                'hint' => "Read more about the <a target='_blank' href='https://www.gov.uk/government/news/hmg-suspends-import-tariffs-on-covid-19-products-to-fight-virus'>suspension of tariffs on COVID-19 critical goods [opens in a new browser window]</a>",
              },
              {
                'code' => '2601',
                'overlay' => 'The product I am importing is not COVID-19 critical',
                'hint' => '',
              },
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
      let(:applicable_additional_codes) do
        {
          '105' => {
            'additional_codes' => [
              { 'code' => '2600' },
              { 'code' => '2601' },
            ],
          },
        }
      end

      it { expect(step.previous_step_path).to eq(customs_value_path) }
    end

    context 'when there are multiple measure type ids on the applicable_additional_codes hash' do
      subject(:step) do
        build(
          :duty_calculator_step_additional_code,
          user_session:,
          measure_type_id:,
        )
      end

      let(:measure_type_id) { '552' }

      it { expect(step.previous_step_path).to eq(additional_codes_path('105')) }
    end
  end

  describe '#next_step_path' do
    context 'when there is just one measure type id on the applicable_additional_codes hash' do
      let(:applicable_additional_codes) do
        {
          '105' => {
            'additional_codes' => [
              { 'code' => '2600' },
              { 'code' => '2601' },
            ],
          },
        }
      end

      it { expect(step.next_step_path).to eq(confirm_path) }
    end

    context 'when there are excise additional codes' do
      let(:applicable_additional_codes) do
        {
          '105' => {
            'additional_codes' => [
              { 'code' => '2600' },
              { 'code' => '2601' },
            ],
          },
          '306' => {
            'additional_codes' => [
              { 'code' => 'X411' },
              { 'code' => 'X444' },
            ],
          },
        }
      end

      it { expect(step.next_step_path).to eq(excise_path('306')) }
    end

    context 'when there are multiple measure type ids on the applicable_additional_codes hash' do
      it { expect(step.next_step_path).to eq(additional_codes_path('552')) }
    end

    context 'when there are less than 2 applicable vat options' do
      let(:applicable_additional_codes) do
        {
          '105' => {
            'additional_codes' => [
              { 'code' => '2600' },
              { 'code' => '2601' },
            ],
          },
        }
      end

      let(:applicable_vat_options) do
        {
          'VATZ' => 'flibble',
        }
      end

      it { expect(step.next_step_path).to eq(confirm_path) }
    end

    context 'when there are more than 1 applicable vat options' do
      let(:applicable_additional_codes) do
        {
          '105' => {
            'additional_codes' => [
              { 'code' => '2600' },
              { 'code' => '2601' },
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

      it { expect(step.next_step_path).to eq(vat_path) }
    end

    context 'when there are available document codes' do
      let(:commodity_code) { '7202999000' }
      let(:measure_type_id) { 105 }

      let(:applicable_additional_codes) do
        {
          '105' => {
            'measure_type_description' => 'third-country duty',
            'heading' => {
              'overlay' => 'Describe your goods in more detail',
              'hint' => 'To trade this commodity, you need to specify an additional 4 digits, known as an additional code',
            },
            'additional_codes' => [
              {
                'code' => '2600',
                'overlay' => 'The product I am importing is COVID-19 critical',
                'hint' => "Read more about the <a target='_blank' href='https://www.gov.uk/government/news/hmg-suspends-import-tariffs-on-covid-19-products-to-fight-virus'>suspension of tariffs on COVID-19 critical goods [opens in a new browser window]</a>",
              },
              {
                'code' => '2601',
                'overlay' => 'The product I am importing is not COVID-19 critical',
                'hint' => '',
              },
            ],
          },
        }
      end

      it { expect(step.next_step_path).to eq(document_codes_path(measure_type_id)) }
    end
  end
end
