RSpec.describe DutyCalculator::Steps::Stopping, :step, :user_session do
  let(:filtered_commodity) { build(:duty_calculator_commodity, :with_multiple_stopping_condition_measures) }

  before do
    allow(DutyCalculator::Api::Commodity).to receive(:build).and_return(filtered_commodity)
  end

  describe '#previous_step_path' do
    subject(:step) { build(:duty_calculator_stopping).previous_step_path }

    context 'when there are document codes' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, :with_multiple_stopping_condition_document_answers) }

      it { is_expected.to eq(document_codes_path('105')) }
    end

    context 'when an optional relief and a declaration are both answered with None' do
      let(:filtered_commodity) do
        build(
          :duty_calculator_commodity,
          import_measures: [
            attributes_for(:duty_calculator_measure, :third_country_tariff),
            attributes_for(:duty_calculator_measure, :autonomous_end_use, :with_stopping_conditions),
            attributes_for(:duty_calculator_measure, :authorised_use_provisions_submission, :with_stopping_conditions),
          ],
        )
      end

      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          document_code: { 'uk' => { '115' => 'None', '464' => 'None' } },
        )
      end

      it 'returns to the declaration question that caused the stop' do
        expect(step).to eq(document_codes_path('464'))
      end
    end

    context 'when the session remembers which answer caused the stop' do
      let(:filtered_commodity) do
        build(
          :duty_calculator_commodity,
          import_measures: [
            attributes_for(:duty_calculator_measure, :third_country_tariff_authorised_use, :with_stopping_conditions),
            attributes_for(:duty_calculator_measure, :tariff_preference, :with_stopping_conditions),
          ],
        )
      end

      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          document_code: { 'uk' => { '105' => 'None', '142' => 'None' } },
          stopping_measure_type_id: '142',
        )
      end

      it 'returns to the question whose answer caused the stop' do
        expect(step).to eq(document_codes_path('142'))
      end
    end

    context 'when the remembered question is not part of this journey' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          :with_multiple_stopping_condition_document_answers,
          stopping_measure_type_id: '464',
        )
      end

      it 'ignores it and falls back to the last rejected question' do
        expect(step).to eq(document_codes_path('105'))
      end
    end

    context 'when there are no document codes' do
      context 'when import date is not set on the session' do
        let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

        it { is_expected.to eq(import_date_path(commodity_code: user_session.commodity_code)) }
      end

      context 'when import date is set on the session' do
        let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, :with_import_date) }

        it {
          expect(step).to eq(
            import_date_path(commodity_code: user_session.commodity_code, day: 1, month: 1, year: 2025),
          )
        }
      end
    end
  end
end
