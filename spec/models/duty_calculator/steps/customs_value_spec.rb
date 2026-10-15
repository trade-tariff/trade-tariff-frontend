RSpec.describe DutyCalculator::Steps::CustomsValue, :step, :user_session do
  subject(:step) do
    build(
      :duty_calculator_customs_value,
      user_session:,
      monetary_value:,
      insurance_cost:,
      shipping_cost:,
    )
  end

  let(:user_session) { build(:duty_calculator_user_session, import_date: '2022-01-01') }
  let(:monetary_value) { '12_500' }
  let(:insurance_cost) { '1_200' }
  let(:shipping_cost) { '340' }

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(
        %w[additional_code document_code excise],
      )
    end
  end

  describe '#validations' do
    context 'when monetary_value is blank' do
      let(:monetary_value) { '' }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:monetary_value].to_a).to eq(
          ['Enter a valid monetary value', 'Enter a numeric monetary value'],
        )
      end
    end

    context 'when monetary_value is 0' do
      let(:monetary_value) { '0' }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:monetary_value].to_a).to eq(
          ['Enter a monetary value greater than zero'],
        )
      end
    end

    context 'when monetary_value is a negative number' do
      let(:monetary_value) { '-999' }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:monetary_value].to_a).to eq(
          ['Enter a monetary value greater than zero'],
        )
      end
    end

    context 'when insurance_cost is blank' do
      let(:monetary_value) { '1234' }
      let(:insurance_cost) { '' }

      it 'is a valid object' do
        expect(step).to be_valid
      end
    end

    context 'when insurance_cost is a negative number' do
      let(:insurance_cost) { '-999' }

      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:insurance_cost].to_a).to eq(
          ['Enter a insurance cost value greater than or equal to zero'],
        )
      end
    end

    context 'when insurance_cost is not numeric' do
      let(:monetary_value) { '1234' }
      let(:insurance_cost) { 'fff' }

      it 'is a not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:insurance_cost].to_a).to eq(
          ['Enter a numeric insurance cost or leave the field blank'],
        )
      end
    end

    context 'when shipping_cost is blank' do
      let(:monetary_value) { '1234' }
      let(:shipping_cost) { '' }

      it 'is a valid object' do
        expect(step).to be_valid
      end
    end

    context 'when shipping_cost is not numeric' do
      let(:monetary_value) { '1234' }
      let(:shipping_cost) { 'fff' }

      it 'is a not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:shipping_cost].to_a).to eq(
          ['Enter a numeric shipping cost or leave the field blank'],
        )
      end
    end

    context 'when shipping_cost is a negative number' do
      let(:monetary_value) { '1234' }
      let(:shipping_cost) { '-999' }

      it 'is a not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error messages' do
        step.valid?

        expect(step.errors.messages[:shipping_cost].to_a).to eq(
          ['Enter a shipping cost value greater than or equal to zero'],
        )
      end
    end
  end

  describe '#save!' do
    it 'saves the monetary_value on to the session' do
      step.save!

      expect(user_session.monetary_value).to eq '12_500'
    end

    it 'saves the insurance_cost on to the session' do
      step.save!

      expect(user_session.insurance_cost).to eq '1_200'
    end

    it 'saves the shipping_cost on to the session' do
      step.save!

      expect(user_session.shipping_cost).to eq '340'
    end
  end

  describe '#previous_step_path' do
    context 'when there is a trade defence and on the GB to NI route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, :with_non_meursing_commodity, trade_defence: true) }

      it { expect(step.previous_step_path).to eq(interstitial_path) }
    end

    context 'when there is no trade defence and on the GB to NI route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, :with_non_meursing_commodity, trade_defence: false) }

      it { expect(step.previous_step_path).to eq(certificate_of_origin_path) }
    end

    context 'when there are applicable meursing codes on the GB to NI route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, :with_meursing_commodity) }

      it { expect(step.previous_step_path).to eq(meursing_additional_codes_path) }
    end

    context 'when on RoW to GB route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_gb_route, :with_non_meursing_commodity) }

      it { expect(step.previous_step_path).to eq(country_of_origin_path) }
    end

    context 'when there is a zero mfn duty and on the Row to NI route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, zero_mfn_duty: true) }

      it { expect(step.previous_step_path).to eq(country_of_origin_path) }
    end

    context 'when the planned processing question has been answered and on the Row to NI route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_non_meursing_commodity, planned_processing: 'commercial_processing') }

      it { expect(step.previous_step_path).to eq(planned_processing_path) }
    end

    context 'when the annual turnover question has been answered and on the Row to NI route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_non_meursing_commodity, :with_small_turnover) }

      it { expect(step.previous_step_path).to eq(annual_turnover_path) }
    end

    context 'when the goods are not for final use and on the Row to NI route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_non_meursing_commodity, final_use: 'no') }

      it { expect(step.previous_step_path).to eq(final_use_path) }
    end

    context 'when there are applicable meursing codes on the Row to NI route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_meursing_commodity) }

      it { expect(step.previous_step_path).to eq(meursing_additional_codes_path) }
    end

    context 'when on the Row to NI route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_non_meursing_commodity) }

      it { expect(step.previous_step_path).to eq(trader_scheme_path) }
    end
  end

  describe '#next_step_path' do
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

    let(:commodity_source) { :uk }
    let(:commodity_code) { '7202118000' }

    let(:filtered_commodity) { DutyCalculator::Api::Commodity.build(commodity_source, commodity_code) }

    before do
      allow(DutyCalculator::Api::Commodity).to receive(:build).and_return(filtered_commodity)
      allow(DutyCalculator::ApplicableMeasureUnitMerger).to receive(:new).and_call_original
      allow(filtered_commodity).to receive(:applicable_measure_units).and_return(applicable_measure_units)
    end

    context 'when there are applicable measure units' do
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

      it 'calls the DutyCalculator::ApplicableMeasureUnitMerger service' do
        step.next_step_path

        expect(DutyCalculator::ApplicableMeasureUnitMerger).to have_received(:new)
      end

      it { expect(step.next_step_path).to eq(measure_amount_path) }
    end

    context 'when there are no applicable measures' do
      let(:applicable_measure_units) { {} }
      let(:session) do
        {
          'answers' => {
            'import_date' => '2022-01-01',
            Steps::MeasureAmount.id => { foo: :bar },
          },
        }
      end

      let(:first_measure_type_id) { '105' }
      let(:applicable_additional_codes) { {} }
      let(:applicable_vat_options) { {} }

      before do
        allow(filtered_commodity).to receive_messages(applicable_additional_codes:, applicable_vat_options:)
      end

      context 'when there are applicable additional codes available' do
        let(:applicable_additional_codes) do
          {
            '105' => {
              'additional_codes' => [
                { 'code' => '2600' },
                { 'code' => '2601' },
              ],
            },

            '552' => {
              'additional_codes' => [
                { 'code' => 'B999' },
                { 'code' => 'B349' },
              ],
            },
          }
        end

        it 'redirects to the additional_codes_path of the first measure type id' do
          expect(
            step.next_step_path,
          ).to eq(
            additional_codes_path(first_measure_type_id),
          )
        end
      end

      context 'when there are excise additional codes' do
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

        it { expect(step.next_step_path).to eq(excise_path('306')) }
      end

      context 'when there are applicable document codes available' do
        let(:commodity_code) { '7202999000' }

        it { expect(step.next_step_path).to eq(document_codes_path('105')) }
      end

      context 'when there is just one VAT option' do
        let(:commodity_code) { '7202999000' }

        it 'redirects to the document_codes_path of the first measure type id' do
          expect(
            step.next_step_path,
          ).to eq(
            document_codes_path(first_measure_type_id),
          )
        end
      end

      context 'when there are multiple VAT options' do
        let(:applicable_vat_options) do
          {
            'VATZ' => 'flibble',
            'VAT' => 'foo',
          }
        end

        it { expect(step.next_step_path).to eq(vat_path) }
      end

      it { expect(step.next_step_path).to eq(confirm_path) }

      it 'removes any leftover value for measure amounts from the session' do
        step.next_step_path

        expect(user_session.measure_amount).to be_empty
      end
    end
  end
end
