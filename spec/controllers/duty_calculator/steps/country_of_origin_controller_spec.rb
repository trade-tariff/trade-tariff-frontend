RSpec.describe DutyCalculator::Steps::CountryOfOriginController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, import_destination: 'XI') }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::CountryOfOrigin)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('country_of_origin/show') }
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: answers }

    let(:answers) do
      {
        duty_calculator_steps_country_of_origin: {
          country_of_origin:,
          other_country_of_origin:,
        },
      }
    end

    context 'when the step answers are valid' do
      let(:country_of_origin) { 'OTHER' }
      let(:other_country_of_origin) { 'AR' }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::CountryOfOrigin)
      end

      it { expect(response).to redirect_to(interstitial_path) }
      it { expect { response }.to change(user_session, :country_of_origin).from(nil).to('OTHER') }
      it { expect { response }.to change(user_session, :other_country_of_origin).from('').to('AR') }
    end

    context 'when the step answers are invalid' do
      let(:country_of_origin) { '' }
      let(:other_country_of_origin) { '' }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::CountryOfOrigin)
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('country_of_origin/show') }
      it { expect { response }.not_to change(user_session, :country_of_origin).from(nil) }
      it { expect { response }.not_to change(user_session, :other_country_of_origin).from('') }
    end
  end
end
