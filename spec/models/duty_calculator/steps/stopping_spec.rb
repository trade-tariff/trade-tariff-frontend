RSpec.describe DutyCalculator::Steps::Stopping, :step, :user_session do
  let(:filtered_commodity) { build(:duty_calculator_commodity, :with_multiple_stopping_condition_measures) }

  before do
    allow(DutyCalculator::Api::Commodity).to receive(:build).and_return(filtered_commodity)
  end

  describe '#previous_step_path' do
    subject(:step) { build(:duty_calculator_stopping).previous_step_path }

    context 'when there are document codes' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, :with_multiple_stopping_condition_document_answers) }

      it { is_expected.to eq(document_codes_path('103')) }
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
