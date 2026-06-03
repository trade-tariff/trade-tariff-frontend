require 'spec_helper'

RSpec.describe ProductExperience::EnquiryFormController, :aggregate_failures, type: :controller do
  let(:draft_id) { SecureRandom.uuid }
  let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }
  let(:submission_token) { SecureRandom.uuid }

  around do |example|
    old_cache_store = ProductExperience::EnquiryFormDraftStore.instance_variable_get(:@cache_store)
    ProductExperience::EnquiryFormDraftStore.cache_store = cache_store
    example.run
  ensure
    ProductExperience::EnquiryFormDraftStore.cache_store = old_cache_store
  end

  before do
    allow(controller).to receive(:set_path_info)
  end

  describe 'GET #show' do
    it 'starts a new enquiry and renders the category step' do
      get :show

      expect(session[:submission_token]).to be_present
      expect(session[:enquiry_form_draft_id]).to be_present
      expect(response).to render_template(:form)
      expect(assigns(:field)).to eq('category')
    end

    it 'clears any stale confirmation reference when starting again' do
      session[:product_experience_enquiry] = { reference_number: 'HDJ2123F' }

      get :show

      expect(session[:product_experience_enquiry]).to be_nil
    end
  end

  describe 'POST #submit' do
    before { start_draft }

    it 'redirects to the start when the submission token is invalid' do
      post :submit, params: { field: 'category', category: 'classification', submission_token: 'wrong-token' }

      expect(response).to redirect_to(product_experience_enquiry_form_path)
      expect(enquiry_data['category']).to be_nil
    end

    it 'validates the category selection' do
      post :submit, params: { field: 'category', submission_token: submission_token }

      expect(response).to render_template(:form)
      expect(assigns(:errors)).to include(field: 'category', message: 'Please select what you need help with.')
    end

    it 'stores classification and redirects to goods details' do
      post :submit, params: { field: 'category', category: 'classification', submission_token: submission_token }

      expect(enquiry_data['category']).to eq('classification')
      expect(response).to redirect_to(product_experience_enquiry_form_field_path('goods_details'))
    end

    it 'stores generic categories and redirects to the query page' do
      post :submit, params: { field: 'category', category: 'origin', submission_token: submission_token }

      expect(enquiry_data['category']).to eq('origin')
      expect(response).to redirect_to(product_experience_enquiry_form_field_path('query'))
    end

    it 'ignores answers that do not belong to the current step' do
      post :submit, params: {
        field: 'category',
        category: 'origin',
        query: 'Do not store me yet',
        submission_token: submission_token,
      }

      expect(enquiry_data).to include('category' => 'origin')
      expect(enquiry_data).not_to include('query')
    end

    it 'shows both required goods detail errors' do
      ProductExperience::EnquiryFormDraftStore.write(draft_id, { category: 'classification' })

      post :submit, params: { field: 'goods_details', submission_token: submission_token }

      expect(response).to render_template(:form)
      expect(assigns(:errors)).to contain_exactly(
        { field: 'goods_product', message: 'Please describe the product.' },
        { field: 'goods_made_of', message: 'Please say what the product is made of.' },
      )
    end

    it 'redirects to check answers when editing' do
      post :submit, params: { field: 'query', query: 'Updated query', editing: 'true', submission_token: submission_token }

      expect(enquiry_data['query']).to eq('Updated query')
      expect(response).to redirect_to(product_experience_enquiry_form_check_your_answers_path)
    end
  end

  describe 'GET #check_your_answers' do
    it 'restarts the journey when the active draft has expired' do
      session[:enquiry_form_draft_id] = draft_id
      session[:submission_token] = submission_token
      allow(Rails.logger).to receive(:warn)

      get :check_your_answers

      expect(response).to redirect_to(product_experience_enquiry_form_path)
      expect(session[:enquiry_form_draft_id]).to be_nil
      expect(session[:submission_token]).to be_nil
      expect(Rails.logger).to have_received(:warn).with(
        "Missing enquiry form draft for session draft id #{draft_id}",
      )
    end
  end

  describe 'POST #submit_form' do
    before do
      start_draft(
        category: 'classification',
        goods_product: 'Embroidery floss',
        goods_made_of: 'Cotton',
        has_commodity_code: 'yes',
        commodity_code: '5204200010',
        email_address: 'trader@example.com',
      )
    end

    it 'submits the enquiry and clears the draft' do
      allow(EnquiryForm).to receive(:create!)
        .and_return({ 'resource_id' => 'HDJ2123F' })

      post :submit_form, params: { submission_token: submission_token }

      expect(EnquiryForm).to have_received(:create!).with(
        hash_including(
          email: 'trader@example.com',
          enquiry_category: 'classification',
          goods_product: 'Embroidery floss',
          commodity_code: '5204200010',
        ),
      )
      expect(response).to redirect_to(product_experience_enquiry_form_confirmation_path)
      expect(session[:submission_token]).to be_nil
      expect(ProductExperience::EnquiryFormDraftStore.read(draft_id)).to be_nil
    end

    it 'preserves the draft when the API does not return a reference' do
      allow(EnquiryForm).to receive(:create!)
        .and_return({ 'resource_id' => nil })

      post :submit_form, params: { submission_token: submission_token }

      expect(response).to redirect_to(product_experience_enquiry_form_check_your_answers_path)
      expect(flash[:alert]).to eq('There was a problem submitting your enquiry. Please try again later.')
      expect(enquiry_data['goods_product']).to eq('Embroidery floss')
    end
  end

  def start_draft(data = {})
    session[:enquiry_form_draft_id] = draft_id
    session[:submission_token] = submission_token
    ProductExperience::EnquiryFormDraftStore.write(draft_id, data)
  end

  def enquiry_data
    ProductExperience::EnquiryFormDraftStore.read(draft_id)
  end
end
