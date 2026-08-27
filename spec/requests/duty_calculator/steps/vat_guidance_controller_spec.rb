RSpec.describe DutyCalculator::Steps::VatGuidanceController, :user_session, type: :request do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, commodity_code:) }
  let(:commodity_code) { '2005202000' }

  before { stub_vat_guidance_demo }

  it 'starts from the duty-calculator commodity and completes its composed route', :aggregate_failures do
    post vat_guidance_start_path
    expect(response).to redirect_to(vat_guidance_question_path)

    get vat_guidance_question_path
    expect(response.body).to include('Is the product supplied in the course of catering?')

    post vat_guidance_answer_path, params: {
      vat_guidance_prototype_answer_form: { answer: 'no' },
    }
    follow_redirect!
    expect(response.body).to include('Is the product packaged and ready to eat?')

    post vat_guidance_answer_path, params: {
      vat_guidance_prototype_answer_form: { answer: 'yes' },
    }
    follow_redirect!

    expect(response.body).to include('Guided VAT result')
    expect(response.body).to include('VATZ')
    expect(response.body).to include('Return to VAT rate selection')
    expect(response.body).to include('not an HMRC determination')
  end

  it 'renders an accessible validation error for an unanswered question', :aggregate_failures do
    post vat_guidance_start_path
    post vat_guidance_answer_path, params: {
      vat_guidance_prototype_answer_form: { answer: '' },
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Error:')
    expect(response.body).to include('can&#39;t be blank')
  end

  it 'keeps the 701/14 food-exception journey inside the VAT step and evidence-only', :aggregate_failures do
    post vat_guidance_start_path, params: { journey_id: 'notice-701-14-food-exceptions' }
    follow_redirect!
    expect(response.body).to include('standard-rated food exception identified by VAT Notice 701/14')

    post vat_guidance_answer_path, params: {
      vat_guidance_prototype_answer_form: { answer: 'no' },
    }
    follow_redirect!

    expect(response.body).to include('Guided VAT result')
    expect(response.body).to include('Evidence-only outcome — no VAT option has been selected.')
    expect(session.dig(described_class::SESSION_KEY, 'candidate_vat')).to be_nil
  end

  it 'keeps the 709/1 catering journey and its 701/14 follow-up inside the VAT step', :aggregate_failures do
    post vat_guidance_start_path, params: { journey_id: 'notice-709-1-catering-reference-expanded' }
    follow_redirect!
    expect(response.body).to include('Is the supply made in the course of catering?')

    post vat_guidance_answer_path, params: {
      vat_guidance_prototype_answer_form: { answer: 'no' },
    }
    follow_redirect!
    expect(response.body).to include('Does the item fall within a standard-rated food exception identified by VAT Notice 701/14?')

    post vat_guidance_answer_path, params: {
      vat_guidance_prototype_answer_form: { answer: 'no' },
    }
    follow_redirect!

    expect(response.body).to include('Guided VAT result')
    expect(response.body).to include('Evidence-only outcome — no VAT option has been selected.')
    expect(session.dig(described_class::SESSION_KEY, 'candidate_vat')).to be_nil
  end

  context 'when the commodity has no composed guidance journey' do
    let(:commodity_code) { '9999999999' }

    it 'returns to the VAT step without starting an unrelated journey', :aggregate_failures do
      post vat_guidance_start_path

      expect(response).to redirect_to(vat_path)
      expect(flash[:alert]).to eq('Guided VAT questions are not available for this commodity.')
    end
  end
end
