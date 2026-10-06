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

  context 'when the duty calculator UX improvements are switched on' do
    render_views

    before do
      allow(TradeTariffFrontend).to receive(:duty_calculator_ux_improvements?).and_return(true)
    end

    describe 'GET #show' do
      subject(:response) { get :show }

      it { expect(response.body).to include('Which VAT rate applies to your import?') }
      it { expect(response.body).to include('Zero-rate VAT (0%)') }
      it { expect(response.body).to include('Standard rate VAT (20%)') }
      it { expect(response.body).to include('I don&#39;t know') }
      it { expect(response.body).to include('Understand different VAT rates') }
      it { expect(response.body).not_to include('checked="checked"') }

      context 'when the trader answered I don\'t know before' do
        let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, vat: 'VAT', vat_assumed: true) }

        it 'keeps I don\'t know selected' do
          response

          expect(assigns[:step].vat).to eq('dont_know')
        end
      end
    end

    describe 'POST #create' do
      subject(:response) { post :create, params: { duty_calculator_steps_vat: { vat: } } }

      context 'when the trader picks a rate' do
        let(:vat) { 'VATZ' }

        it { expect(response).to redirect_to(confirm_path) }
        it { expect { response }.to change(user_session, :vat).from(nil).to('VATZ') }
        it { expect { response }.to change(user_session, :vat_assumed).from(nil).to(false) }
      end

      context 'when the trader does not know the rate' do
        let(:vat) { 'dont_know' }

        it { expect(response).to redirect_to(confirm_path) }
        it { expect { response }.to change(user_session, :vat).from(nil).to('VAT') }
        it { expect { response }.to change(user_session, :vat_assumed).from(nil).to(true) }
      end

      context 'when nothing is selected' do
        let(:vat) { '' }

        it { expect(response.body).to include('Select one of the available options') }
      end
    end
  end

  context 'when the duty calculator UX improvements are switched off' do
    subject(:response) { post :create, params: { duty_calculator_steps_vat: { vat: 'dont_know' } } }

    it 'does not treat I don\'t know as an assumed rate' do
      response

      expect(user_session.vat_assumed).to be_nil
    end
  end

  context 'when an assumed VAT answer was cleared' do
    let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, vat: nil, vat_assumed: true) }

    before do
      allow(TradeTariffFrontend).to receive(:duty_calculator_ux_improvements?).and_return(true)
    end

    it 'does not pre-select I don\'t know' do
      get :show

      expect(assigns[:step].vat).to be_nil
    end
  end
end
