RSpec.describe DutyCalculator::Steps::Interstitial, :step, :user_session do
  subject(:step) { described_class.new }

  let(:user_session) { build(:duty_calculator_user_session) }

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it { expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(%w[meursing_additional_code]) }
  end

  describe '#next_step_path' do
    context 'when on a meursing route with applicable meursing codes' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, :with_meursing_commodity) }

      it { expect(step.next_step_path).to eq(meursing_additional_codes_path) }
    end

    context 'when on a meursing route with no applicable meursing codes' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, :with_non_meursing_commodity) }

      it { expect(step.next_step_path).to eq(customs_value_path) }
    end

    context 'when not on a meursing route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_gb_route) }

      it { expect(step.next_step_path).to eq(customs_value_path) }
    end
  end

  describe '#previous_step_path' do
    context 'when on GB to NI route with a negative certificate of origin answer' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, certificate_of_origin: 'no') }

      it { expect(step.previous_step_path).to eq(certificate_of_origin_path) }
    end

    context 'when on GB to NI route with no certificate of origin answer' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route) }

      it { expect(step.previous_step_path).to eq(country_of_origin_path) }
    end

    context 'when on the ROW to NI route and there is a trade defence in place' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, trade_defence: true) }

      it { expect(step.previous_step_path).to eq(country_of_origin_path) }
    end

    context 'when on the ROW to NI route and goods are for commercial processing' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, planned_processing: 'commercial_purposes') }

      it { expect(step.previous_step_path).to eq(planned_processing_path) }
    end

    context 'when on the ROW to NI route and goods are not for final use' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, final_use: 'no') }

      it { expect(step.previous_step_path).to eq(final_use_path) }
    end

    context 'when on the ROW to NI route and the trader is not part of the trusted trader scheme' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, trader_scheme: 'no') }

      it { expect(step.previous_step_path).to eq(trader_scheme_path) }
    end
  end
end
