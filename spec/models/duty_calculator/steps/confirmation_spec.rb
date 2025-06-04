RSpec.describe DutyCalculator::Steps::Confirmation, :step, :user_session do
  subject(:step) { build(:duty_calculator_confirmation) }

  let(:filtered_commodity) do
    instance_double(
      DutyCalculator::Api::Commodity,
      applicable_additional_codes:,
      applicable_vat_options:,
    )
  end

  let(:applicable_vat_options) { {} }
  let(:applicable_additional_codes) { {} }
  let(:user_session) { build(:duty_calculator_user_session) }

  before do
    allow(DutyCalculator::Api::Commodity).to receive(:build).and_return(filtered_commodity)
  end

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(%w[])
    end
  end

  describe '#next_step_path' do
    it 'return duty path' do
      expect(
        step.next_step_path,
      ).to eq(
        duty_path,
      )
    end
  end

  describe '#previous_step_path' do
    context 'when there are more than one applicable vat options' do
      let(:applicable_vat_options) do
        {
          'VATZ' => 'flibble',
          'VATR' => 'foobar',
        }
      end

      it { expect(step.previous_step_path).to eq(vat_path) }
    end

    context 'when there us just one applicable vat option available' do
      let(:applicable_vat_options) do
        {
          'VATZ' => 'flibble',
        }
      end

      it { expect(step.previous_step_path).to eq(customs_value_path) }
    end

    context 'when there are additional codes on the session' do
      let(:user_session) { build(:duty_calculator_user_session, :with_additional_codes) }

      it { expect(step.previous_step_path).to eq(additional_codes_path('103')) }
    end

    context 'when there are excise additional codes' do
      let(:user_session) { build(:duty_calculator_user_session, :with_excise_additional_codes) }

      it { expect(step.previous_step_path).to eq(excise_path('DBC')) }
    end

    context 'when there are measure amounts on the session' do
      let(:user_session) { build(:duty_calculator_user_session, :with_measure_amount) }

      it { expect(step.previous_step_path).to eq(measure_amount_path) }
    end

    context 'when there are no measure amounts on the session' do
      let(:user_session) { build(:duty_calculator_user_session) }

      it { expect(step.previous_step_path).to eq(customs_value_path) }
    end
  end
end
