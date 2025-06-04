RSpec.describe DutyCalculator::Steps::VatController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::Vat)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('vat/show') }
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: answers }

    let(:answers) do
      {
        duty_calculator_steps_vat: vat,
      }
    end

    context 'when the step answers are valid' do
      let(:vat) { attributes_for(:duty_calculator_vat, vat: 'VATE') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::Vat)
      end

      it { expect(response).to redirect_to(confirm_path) }
      it { expect { response }.to change(user_session, :vat).from(nil).to('VATE') }
    end

    context 'when the step answers are invalid' do
      let(:vat) { attributes_for(:duty_calculator_vat, vat: '') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::Vat)
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('vat/show') }
      it { expect { response }.not_to change(user_session, :vat).from(nil) }
    end
  end
end
