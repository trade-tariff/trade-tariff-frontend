RSpec.describe DutyCalculator::Steps::MeursingAdditionalCodesController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::MeursingAdditionalCode)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('meursing_additional_codes/show') }
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: answers }

    let(:answers) do
      {
        duty_calculator_steps_meursing_additional_code: { meursing_additional_code: },
      }
    end

    context 'when the step answers are valid' do
      let(:meursing_additional_code) { '000' }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::MeursingAdditionalCode)
      end

      it { expect { response }.to change(user_session, :meursing_additional_code).from(nil).to('000') }
      it { expect(response).to redirect_to(customs_value_path) }
    end

    context 'when the step answers are invalid' do
      let(:meursing_additional_code) { '' }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::MeursingAdditionalCode)
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('meursing_additional_codes/show') }
      it { expect { response }.not_to change(user_session, :meursing_additional_code).from(nil) }
    end
  end
end
