RSpec.describe DutyCalculator::Steps::MeursingAdditionalCode, :step, :user_session do
  subject(:step) { build(:duty_calculator_meursing_additional_code, meursing_additional_code:) }

  let(:meursing_additional_code) { nil }

  let(:user_session) { build(:duty_calculator_user_session) }

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(%w[])
    end
  end

  describe '#validations' do
    context 'when meursing_additional_code_code is formatted correctly' do
      let(:meursing_additional_code) { '000' }

      it { expect(step).to be_valid }

      it 'has no validation errors' do
        step.valid?

        expect(step.errors.messages[:meursing_additional_code]).to be_empty
      end
    end

    context 'when meursing_additional_code_code is not formatted correctly' do
      let(:meursing_additional_code) { 'flibble' }

      it { expect(step).not_to be_valid }

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:meursing_additional_code]).to eq(['Specify a valid 3-digit Meursing additional code', 'Enter a valid Meursing code'])
      end
    end
  end

  describe '#save!' do
    let(:meursing_additional_code) { '000' }

    it 'saves the meursing_additional_code_code to the session' do
      expect { step.save! }.to change(user_session, :meursing_additional_code).from(nil).to('000')
    end
  end

  describe '#next_step_path' do
    it { expect(step.next_step_path).to eq(customs_value_path) }
  end

  describe '#previous_step_path' do
    context 'when annual_turnover is less than 500k' do
      let(:user_session) { build(:duty_calculator_user_session, :with_small_turnover) }

      it { expect(step.previous_step_path).to eq(annual_turnover_path) }
    end

    context 'when the planned processing is acceptable' do
      let(:user_session) { build(:duty_calculator_user_session, planned_processing: 'without_any_processing') }

      it { expect(step.previous_step_path).to eq(planned_processing_path) }
    end

    context 'when the planned processing is unacceptable' do
      let(:user_session) { build(:duty_calculator_user_session, planned_processing: 'commercial_purposes') }

      it { expect(step.previous_step_path).to eq(interstitial_path) }
    end

    context 'when the planned processing is not answered' do
      let(:user_session) { build(:duty_calculator_user_session) }

      it { expect(step.previous_step_path).to eq(interstitial_path) }
    end
  end
end
