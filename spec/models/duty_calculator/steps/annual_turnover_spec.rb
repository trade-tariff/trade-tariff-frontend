RSpec.describe DutyCalculator::Steps::AnnualTurnover, :step, :user_session do
  subject(:step) { build(:duty_calculator_annual_turnover, user_session:, annual_turnover:) }

  let(:user_session) { build(:duty_calculator_user_session) }
  let(:annual_turnover) { '' }

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(
        %w[
          planned_processing
          certificate_of_origin
          document_code
          excise
          vat
        ],
      )
    end
  end

  describe '#validations' do
    context 'when annual_turnover answer is blank' do
      let(:annual_turnover) { '' }

      it { expect(step).not_to be_valid }

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:annual_turnover]).to eq(['Select one of the two options'])
      end
    end

    context 'when annual_turnover answer is present' do
      let(:annual_turnover) { 'no' }

      it { expect(step).to be_valid }

      it 'has no validation errors' do
        step.valid?

        expect(step.errors.messages[:annual_turnover]).to be_empty
      end
    end
  end

  describe '#save!' do
    let(:annual_turnover) { 'yes' }

    it 'saves the annual_turnover to the session' do
      expect { step.save! }.to change(user_session, :annual_turnover).from(nil).to('yes')
    end
  end

  describe '#next_step_path' do
    context 'when annual_turnover is less than 500k and on the gb to ni route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, :with_small_turnover) }

      it { expect(step.next_step_path).to eq(duty_path) }
    end

    context 'when annual_turnover is more than 500k and on the gb to ni route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, :with_large_turnover) }

      it { expect(step.next_step_path).to eq(planned_processing_path) }
    end

    context 'when annual_turnover is less than 500k and on the row to ni route with no meursing codes' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_small_turnover, :with_non_meursing_commodity) }

      it { expect(step.next_step_path).to eq(customs_value_path) }
    end

    context 'when annual_turnover is less than 500k and on the row to ni route with meursing codes' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_small_turnover, :with_meursing_commodity) }

      it { expect(step.next_step_path).to eq(meursing_additional_codes_path) }
    end

    context 'when annual_turnover is more than 500k and on the row to ni route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_large_turnover) }

      it { expect(step.next_step_path).to eq(planned_processing_path) }
    end
  end

  describe '#previous_step_path' do
    it { expect(step.previous_step_path).to eq(final_use_path) }
  end
end
