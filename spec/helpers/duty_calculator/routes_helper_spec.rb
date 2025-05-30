RSpec.describe DutyCalculator::RoutesHelper, :user_session do
  describe '#current_route' do
    subject(:current_route) { helper.current_route }

    context 'when on a gb to ni route' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route) }

      it { is_expected.to eq(:gb_to_ni) }
    end

    context 'when on any other route' do
      let(:user_session) { build(:duty_calculator_user_session) }

      it { is_expected.to eq(:row_to_ni) }
    end
  end
end
