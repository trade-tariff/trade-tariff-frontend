RSpec.describe DutyCalculator::Steps::StoppingController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::Stopping)
    end

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('stopping/show') }
  end
end
