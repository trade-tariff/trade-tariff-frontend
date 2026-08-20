RSpec.describe VatGuidancePrototype::JourneysController, type: :request do
  describe 'GET /vat-guidance-prototype' do
    it 'shows all reviewed, currently supported examples', :aggregate_failures do
      get vat_guidance_prototype_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Guided VAT determination')
      expect(response.body).to include('must not be used to make a VAT declaration')
      expect(response.body).to include('Vegetable fat and oil blend consigned from Canada')
      expect(response.body).to include('1516209821')
      expect(response.body).to include('Live bees')
      expect(response.body).to include('0106410000')
      expect(response.body).to include('Children&#39;s picture, drawing or colouring books')
      expect(response.body).to include('4903000000')
      expect(response.body).to include('Vegetable and strawberry plants')
      expect(response.body).to include('0602903000')
      expect(response.body).not_to include('Cherry tomatoes')
      expect(response.body).not_to include('Fresh plums')
      expect(response.body).not_to include('Breeding sows')
    end
  end

  describe 'the determined journey' do
    it 'asks successive questions and returns a tariff option', :aggregate_failures do
      post vat_guidance_prototype_start_path, params: { journey_id: 'vegetable_oil_blend' }
      expect(response).to redirect_to(vat_guidance_prototype_question_path)

      get vat_guidance_prototype_question_path
      expect(response.body).to include('vegetable fat and oil blend')

      post vat_guidance_prototype_answer_path, params: {
        vat_guidance_prototype_answer_form: { answer: 'yes' },
      }
      post vat_guidance_prototype_answer_path, params: {
        vat_guidance_prototype_answer_form: { answer: 'animal_feed' },
      }
      post vat_guidance_prototype_answer_path, params: {
        vat_guidance_prototype_answer_form: { answer: 'yes' },
      }

      get vat_guidance_prototype_result_path
      expect(response.body).to include('Prototype VAT option')
      expect(response.body).to include('VAT zero rate')
      expect(response.body).to include('VATZ')
    end
  end

  describe 'an unanswered question' do
    it 'renders an accessible validation error', :aggregate_failures do
      post vat_guidance_prototype_start_path, params: { journey_id: 'vegetable_oil_blend' }
      post vat_guidance_prototype_answer_path, params: {
        vat_guidance_prototype_answer_form: { answer: '' },
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Error:')
      expect(response.body).to include('can&#39;t be blank')
    end
  end

  describe 'an intentionally indeterminate journey' do
    it 'explains why it did not guess', :aggregate_failures do
      post vat_guidance_prototype_start_path, params: { journey_id: 'vegetable_oil_blend' }
      post vat_guidance_prototype_answer_path, params: {
        vat_guidance_prototype_answer_form: { answer: 'yes' },
      }
      post vat_guidance_prototype_answer_path, params: {
        vat_guidance_prototype_answer_form: { answer: 'other_fuel' },
      }
      get vat_guidance_prototype_result_path

      expect(response.body).to include('VAT option not determined')
      expect(response.body).to include('does not guess')
      expect(response.body).to include('not present in this commodity')
    end
  end
end
