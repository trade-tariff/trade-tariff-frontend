RSpec.describe DutyCalculator::Steps::VatGuidanceController, :user_session do
  render_views

  let(:user_session) do
    build(
      :duty_calculator_user_session,
      :with_commodity_information,
      commodity_code: '1516209821',
      import_date: '2026-07-21',
    )
  end
  let(:vat_options) do
    {
      'VATZ' => 'VAT zero rate (0.0%)',
      'VAT' => 'Value added tax (20.0%)',
    }
  end

  before do
    allow(TradeTariffFrontend).to receive(:vat_guidance_enabled?).and_return(true)
    allow(controller).to receive(:applicable_vat_options).and_return(vat_options)
  end

  describe 'GET #show' do
    it 'starts the mapped journey using the duty calculator commodity', :aggregate_failures do
      get :show

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('vat_guidance/show')
      expect(response.body).to include('vegetable fat and oil blend')
      expect(response.body).to include('Reviewed rule set')
      expect(response.body).to include('Animal feed oils')
    end

    context 'with an eligible commodity that does not have an approved rule set' do
      before do
        repository = instance_double(VatGuidancePrototype::RuleRepository, find_by_commodity: nil)
        allow(VatGuidancePrototype::RuleRepository).to receive(:default).and_return(repository)
      end

      it 'starts a generic confirmation journey using all live tariff choices', :aggregate_failures do
        get :show

        expect(response).to have_http_status(:ok)
        expect(response).to render_template('vat_guidance/show')
        expect(response.body).to include('Product-specific guided questions have not been reviewed')
        expect(response.body).to include('Have you confirmed which VAT treatment applies')
        expect(response.body).to include('Generic fallback')
      end
    end

    context 'with a commodity that has only one VAT option' do
      let(:vat_options) { { 'VAT' => 'Value added tax (20.0%)' } }

      it 'returns to the normal calculator flow' do
        get :show

        expect(response).to redirect_to(confirm_path)
      end
    end

    context 'when the feature is disabled' do
      before do
        allow(TradeTariffFrontend).to receive(:vat_guidance_enabled?).and_return(false)
      end

      it 'returns to the VAT selection step' do
        get :show

        expect(response).to redirect_to(vat_path)
      end
    end
  end

  describe 'the complete guided journey' do
    def answer(value)
      post :answer, params: {
        vat_guidance_prototype_answer_form: { answer: value },
      }
    end

    it 'applies the determined live tariff option and returns to check answers', :aggregate_failures do
      get :show
      answer('yes')
      answer('animal_feed')
      answer('yes')

      get :result
      expect(response.body).to include('VAT zero rate')
      expect(response.body).to include('Animals and animal food (VAT Notice 701/15)')

      expect { post :apply }.to change(user_session, :vat).from(nil).to('VATZ')
      expect(response).to redirect_to(confirm_path)
    end

    it 'renders an accessible validation error for an unanswered question', :aggregate_failures do
      get :show
      answer('')

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Error:')
      expect(response.body).to include('can&#39;t be blank')
    end
  end

  describe 'the generic journey for any other multi-option commodity' do
    before do
      repository = instance_double(VatGuidancePrototype::RuleRepository, find_by_commodity: nil)
      allow(VatGuidancePrototype::RuleRepository).to receive(:default).and_return(repository)
    end

    def answer(value)
      post :answer, params: {
        vat_guidance_prototype_answer_form: { answer: value },
      }
    end

    it 'applies an independently confirmed option that is present in live tariff data', :aggregate_failures do
      get :show
      answer('yes')
      answer('VAT')

      get :result
      expect(response.body).to include('Value added tax (20.0%)')
      expect(response.body).to include('You confirmed this treatment independently')
      expect(response.body).to include('Guidance to check')

      expect { post :apply }.to change(user_session, :vat).from(nil).to('VAT')
      expect(response).to redirect_to(confirm_path)
    end

    it 'does not select a rate without independent confirmation', :aggregate_failures do
      get :show
      answer('no')

      get :result
      expect(response.body).to include('VAT rate not determined')
      expect(response.body).to include('obtain professional advice')
      expect { post :apply }.not_to change(user_session, :vat)
    end
  end
end
