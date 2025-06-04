RSpec.describe DutyCalculator::Steps::DocumentCodesController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, commodity_code: '1516209821') }

  describe 'GET #show' do
    subject(:response) { get :show, params: { measure_type_id: '117' } }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::DocumentCode)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('document_codes/show') }
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: { measure_type_id: '117' }.merge(answers) }

    let(:answers) do
      {
        duty_calculator_steps_document_code: {
          document_code_uk:,
          document_code_xi:,
        },
      }
    end

    context 'when the step answers are valid' do
      let(:document_code_uk) { 'C990' }
      let(:document_code_xi) { '' }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::DocumentCode)
      end

      it { expect(response).to redirect_to(vat_path) }
      it { expect { response }.to change(user_session, :document_code_uk).from({}).to('117' => 'C990') }
      it { expect { response }.to change(user_session, :document_code_xi).from({}).to('117' => '') }
    end
  end
end
