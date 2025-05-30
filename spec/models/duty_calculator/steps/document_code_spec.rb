RSpec.describe DutyCalculator::Steps::DocumentCode, :step, :user_session do
  subject(:step) { build(:duty_calculator_document_code, measure_type_id:) }

  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }
  let(:commodity_source) { :uk }
  let(:commodity_code) { '7202999000' }
  let(:measure_type_id) { 117 }

  let(:filtered_commodity) do
    DutyCalculator::Api::Commodity.build(
      commodity_source,
      commodity_code,
    )
  end

  let(:applicable_vat_options) { {} }
  let(:additional_codes) { {} }
  let(:stopping_conditions_met) { false }

  before do
    allow(DutyCalculator::Api::Commodity).to receive(:build).and_return(filtered_commodity)
    allow(filtered_commodity).to receive_messages(applicable_additional_codes: additional_codes, stopping_conditions_met?: stopping_conditions_met, applicable_vat_options:)
  end

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(
        %w[],
      )
    end
  end

  describe '#save!' do
    it 'saves the document codes for uk on to the session' do
      expect { step.save! }.to change(user_session, :document_code_uk).from({}).to('117' => 'C644')
    end

    it 'saves the document codes for xi on to the session' do
      expect { step.save! }.to change(user_session, :document_code_xi).from({}).to('117' => 'N851')
    end
  end

  describe '#options_for' do
    subject(:options) { step.options_for(source) }

    context 'when loading from the `uk` source' do
      let(:source) { 'uk' }
      let(:expected_options) do
        [
          OpenStruct.new(
            id: 'C990',
            name: 'C990 - ',
          ),
          OpenStruct.new(
            id: 'None',
            name: 'None of the above',
          ),
        ]
      end

      it { expect(options).to eq(expected_options) }
    end

    context 'when loading from the `xi` source' do
      let(:source) { 'xi' }
      let(:expected_options) { [] }

      it { expect(options).to eq(expected_options) }
    end
  end

  describe '#document_code_uk' do
    it { expect(step.document_code_uk).to eq('C644') }

    context 'when there is no document code being passed in, but the value is on the session' do
      subject(:step) do
        build(
          :duty_calculator_document_code,
          user_session:,
          document_code_uk: nil,
          measure_type_id:,
        )
      end

      let(:measure_type_id) { '105' }
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_document_codes,
          :with_commodity_information,
        )
      end

      it { is_expected.to be_valid }

      it 'returns the value from the session that corresponds to measure type 105' do
        expect(step.document_code_uk).to eq('C644')
      end
    end
  end

  describe '#document_code_xi' do
    it { is_expected.to be_valid }
    it { expect(step.document_code_xi).to eq('N851') }

    context 'when there is no document code being passed in, but the value is on the session' do
      subject(:step) do
        build(
          :duty_calculator_document_code,
          user_session:,
          document_code_xi: nil,
          measure_type_id:,
        )
      end

      let(:measure_type_id) { '142' }

      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_document_codes,
          :with_commodity_information,
        )
      end

      it { is_expected.to be_valid }
      it { expect(step.document_code_xi).to eq('N851') }
    end
  end

  describe '#valid?' do
    before do
      # rubocop:disable RSpec/SubjectStub
      allow(step).to receive(:applicable_document_codes).and_return(applicable_document_codes)
      # rubocop:enable RSpec/SubjectStub
    end

    let(:applicable_document_codes) { {} }

    it { is_expected.to be_valid }

    context 'when both document_code_uk and document_code_xi are not present' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, :deltas_applicable) }

      context 'when the uk and xi service return the same document codes' do
        subject(:step) do
          build(
            :duty_calculator_document_code,
            document_code_uk: nil,
            document_code_xi: nil,
          )
        end

        let(:applicable_document_codes) do
          {
            'uk' => {
              '117' => [
                { code: 'C990', description: 'End use authorisation ships and platforms (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)' },
                { code: '', description: nil },
              ],
            },
            'xi' => {
              '117' => [
                { code: 'C990', description: 'End use authorisation ships and platforms (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)' },
                { code: '', description: nil },
              ],
            },
          }
        end

        it { is_expected.not_to be_valid }

        it 'adds the correct validation error messages for the uk attribute' do
          step.valid?

          expect(step.errors.messages[:document_code_uk].to_a).to eq(['Specify a valid option'])
        end

        it 'adds the correct validation error messages for the xi attribute' do
          step.valid?

          expect(step.errors.messages[:document_code_xi].to_a).to eq([])
        end
      end

      context 'when the uk service returns the document codes the xi service does not' do
        subject(:step) do
          build(
            :duty_calculator_document_code,
            document_code_uk: nil,
            document_code_xi: nil,
          )
        end

        let(:applicable_document_codes) do
          {
            'uk' => {
              '117' => [
                { code: 'C990', description: 'End use authorisation ships and platforms (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)' },
                { code: '', description: nil },
              ],
            },
          }
        end

        it { is_expected.not_to be_valid }

        it 'adds the correct validation error messages for the uk attribute' do
          step.valid?

          expect(step.errors.messages[:document_code_uk].to_a).to eq(['Specify a valid option'])
        end

        it 'adds the correct validation error messages for the xi attribute' do
          step.valid?

          expect(step.errors.messages[:document_code_xi].to_a).to eq([])
        end
      end

      context 'when the xi service returns document codes the uk service does not have' do
        subject(:step) do
          build(
            :duty_calculator_document_code,
            document_code_uk: nil,
            document_code_xi: nil,
          )
        end

        let(:applicable_document_codes) do
          {
            'xi' => {
              '117' => [
                { code: 'C990', description: 'End use authorisation ships and platforms (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)' },
                { code: '', description: nil },
              ],
            },
          }
        end

        it { is_expected.not_to be_valid }

        it 'adds the correct validation error messages for the uk attribute' do
          step.valid?

          expect(step.errors.messages[:document_code_uk].to_a).to eq([])
        end

        it 'adds the correct validation error messages for the xi attribute' do
          step.valid?

          expect(step.errors.messages[:document_code_xi].to_a).to eq(['Specify a valid option'])
        end
      end
    end

    context 'when the document_code_uk is not present' do
      subject(:step) do
        build(
          :duty_calculator_document_code,
          document_code_uk: nil,
        )
      end

      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, commodity_source: 'uk') }

      it { is_expected.not_to be_valid }

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:document_code_uk].to_a).to eq(['Specify a valid option'])
      end
    end

    context 'when the document_code_xi is not present' do
      subject(:step) do
        build(
          :duty_calculator_document_code,
          document_code_xi: nil,
        )
      end

      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, commodity_source: 'xi') }

      it { is_expected.not_to be_valid }

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:document_code_xi].to_a).to eq(['Specify a valid option'])
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

      let(:measure_type_id) { 105 }

      it { expect(step.previous_step_path).to eq(measure_amount_path) }

      it 'calls the DutyCalculator::ApplicableMeasureUnitMerger service' do
        step.previous_step_path

        expect(DutyCalculator::ApplicableMeasureUnitMerger).to have_received(:new)
      end
    end

    context 'when there is just one measure type id available and no measure units are available' do
      let(:measure_type_id) { 105 }

      it 'returns the customs path' do
        expect(step.previous_step_path).to eq(customs_value_path)
      end
    end

    context 'when there are multiple measure type ids on the applicable_additional_codes hash' do
      subject(:step) do
        build(
          :duty_calculator_document_code,
          user_session:,
          measure_type_id:,
        )
      end

      let(:measure_type_id) { 105 }

      let(:additional_codes) do
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

      it 'returns additional_codes_path with the previous measure_type_id as argument' do
        expect(step.previous_step_path).to eq(additional_codes_path('105'))
      end
    end

    context 'when there are multiple measure type ids on the applicable_document_codes hash' do
      subject(:step) do
        build(
          :duty_calculator_document_code,
          user_session:,
          measure_type_id:,
        )
      end

      let(:measure_type_id) { 117 }

      it 'returns document_codes_path with the previous measure_type_id as argument' do
        expect(step.previous_step_path).to eq(document_codes_path(105))
      end
    end
  end

  describe '#next_step_path' do
    context 'when there is just one measure type id on the applicable_document_codes
    hash' do
      it { expect(step.next_step_path).to eq(confirm_path) }
    end

    context 'when there are multiple measure type ids on the applicable_document_codes hash' do
      let(:measure_type_id) { 105 }

      it { expect(step.next_step_path).to eq(document_codes_path(117)) }
    end

    context 'when there are multiple measure type ids on the applicable_document_codes and stopping conditions are met' do
      let(:measure_type_id) { 117 }
      let(:stopping_conditions_met) { true }

      it { expect(step.next_step_path).to eq(stopping_path) }
    end

    context 'when there are less than 2 applicable vat options' do
      let(:additional_codes) do
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
      let(:additional_codes) do
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
end
