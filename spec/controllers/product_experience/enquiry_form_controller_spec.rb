require 'spec_helper'

RSpec.describe ProductExperience::EnquiryFormController, type: :controller do
  let(:reference_number) { 'R1M5X8LU' }
  let(:enquiry_form) { build(:enquiry_form, reference_number: reference_number) }

  let(:session_data) do
    {
      'full_name' => enquiry_form.name,
      'company_name' => enquiry_form.company_name,
      'occupation' => enquiry_form.job_title,
      'email_address' => enquiry_form.email,
      'category' => enquiry_form.enquiry_category,
      'query' => enquiry_form.enquiry_description,
    }
  end

  let(:attributes) do
    {
      name: session_data['full_name'],
      company_name: session_data['company_name'],
      job_title: session_data['occupation'],
      email: session_data['email_address'],
      enquiry_category: session_data['category'],
      enquiry_description: session_data['query'],
    }
  end

  before do
    allow(controller).to receive(:set_path_info)
    allow(EnquiryFormHelper).to receive(:fields).and_return(%w[full_name email_address query])
  end

  describe 'GET #show' do
    it 'resets enquiry_data session' do
      get :show
      expect(session[:enquiry_data]).to eq({})
    end
  end

  describe 'GET #form' do
    let(:submission_token) { SecureRandom.uuid }

    before { session[:submission_token] = submission_token }

    context 'with valid field and correct token' do
      it 'renders the form' do
        get :form, params: { field: 'full_name', submission_token: submission_token }
        expect(response).to render_template(:form)
      end
    end
  end

  describe 'POST #submit' do
    let(:submission_token) { SecureRandom.uuid }

    before { session[:submission_token] = submission_token }

    context 'with valid token' do
      it 'saves the field value' do
        post :submit, params: { field: 'full_name', full_name: 'Jane Doe', submission_token: submission_token }
        expect(session[:enquiry_data]['full_name']).to eq('Jane Doe')
      end
    end

    context 'with invalid token' do
      it 'redirects back to the start' do
        post :submit, params: { field: 'full_name', full_name: 'Jane Doe', submission_token: 'wrong-token' }
        expect(response).to redirect_to(product_experience_enquiry_form_path)
      end
    end

    context 'with missing required field' do
      before { post :submit, params: { field: 'full_name', full_name: '', submission_token: submission_token } }

      it { expect(assigns(:alert)).to be_present }

      it { expect(assigns(:prev_field)).to be_nil }

      it { expect(response).to render_template(:form) }
    end

    context 'with invalid email' do
      before do
        allow(controller).to receive(:previous_field).with('email_address').and_return('occupation')
        post :submit, params: { field: 'email_address', email_address: 'bad-email', submission_token: submission_token }
      end

      it { expect(assigns(:alert)).to eq('Please enter a valid email address.') }
      it { expect(assigns(:prev_field)).to eq('occupation') }
      it { expect(response).to render_template(:form) }
    end

    context 'with valid submission' do
      before { post :submit, params: { field: 'full_name', full_name: 'John Doe', submission_token: submission_token } }

      it { expect(session[:enquiry_data]['full_name']).to eq('John Doe') }

      it {
        expect(response).to redirect_to(
          controller: 'product_experience/enquiry_form',
          action: 'form',
          field: 'email_address',
        )
      }
    end

    context 'when editing' do
      before { post :submit, params: { field: 'query', query: 'Some question?', editing: 'true', submission_token: submission_token } }

      it { expect(response).to redirect_to(product_experience_enquiry_form_check_your_answers_path) }
    end

    context 'when editing and no submission token' do
      before { post :submit, params: { field: 'query', query: 'Some question?', editing: 'true', submission_token: nil } }

      it { expect(response).to redirect_to(product_experience_enquiry_form_path) }
    end
  end

  describe 'GET #check_your_answers' do
    before do
      session[:enquiry_data] = { 'query' => 'Test question' }
      allow(Rails.cache).to receive(:read).with(session[:enquiry_data]['query']).and_return(session[:enquiry_data]['query'])
      get :check_your_answers
    end

    it { expect(assigns(:enquiry_data)).to eq({ 'query' => 'Test question' }) }
    it { expect(response).to be_successful }
  end

  describe 'POST #submit_form' do
    let(:resource_id) { 'R1M5X8LU' }
    let(:submission_token) { SecureRandom.uuid }

    before do
      session[:enquiry_data] = session_data
      session[:submission_token] = submission_token
      allow(Rails.cache).to receive(:read).with(session[:enquiry_data]['query']).and_return(session[:enquiry_data]['query'])
    end

    context 'when submission is successful' do
      before do
        stub_api_request('enquiry_form/submissions', :post)
          .with(
            body: hash_including(data: { attributes: attributes }),
            headers: { 'Content-Type' => 'application/json' },
          )
          .and_return(jsonapi_response(:enquiry_form_submission, { resource_id: resource_id }))
        session[:reference_number] = resource_id
      end

      it 'redirects to the confirmation page' do
        post :submit_form, params: { submission_token: submission_token }

        expect(response).to redirect_to(
          product_experience_enquiry_form_confirmation_path,
        )
      end

      it 'clears the session token' do
        post :submit_form, params: { submission_token: submission_token }
        expect(session[:submission_token]).to be_nil
      end
    end

    context 'when API succeeds but no reference number returned' do
      before do
        stub_api_request('enquiry_form/submissions', :post)
          .with(
            body: hash_including(data: { attributes: attributes }),
            headers: { 'Content-Type' => 'application/json' },
          )
          .and_return(jsonapi_response(:enquiry_form_submission, {}))
      end

      it 'creates error message' do
        post :submit_form, params: { submission_token: submission_token }
        expect(flash[:alert]).to eq('There was a problem submitting your enquiry. Please try again later.')
      end

      it 'redirects to check your answers' do
        post :submit_form, params: { submission_token: submission_token }
        expect(response).to redirect_to(product_experience_enquiry_form_check_your_answers_path)
      end
    end

    context 'when API call raises an error' do
      before do
        allow(EnquiryForm).to receive(:create!).and_raise(Faraday::TimeoutError.new('Timeout'))
      end

      it 'creates error message' do
        post :submit_form, params: { submission_token: submission_token }
        expect(flash[:alert]).to eq('There was a problem submitting your enquiry. Please try again later.')
      end

      it 'redirects to check your answers' do
        post :submit_form, params: { submission_token: submission_token }
        expect(response).to redirect_to(product_experience_enquiry_form_check_your_answers_path)
      end
    end

    context 'when the submission token is invalid or missing' do
      it 'does not submit and redirects with an error' do
        post :submit_form, params: { submission_token: 'invalid-token' }

        expect(response).to redirect_to(product_experience_enquiry_form_path)
      end
    end
  end

  describe 'GET #confirmation' do
    let(:reference_number) { 'R1M5X8LU' }

    context 'when reference number is present' do
      before do
        session[:product_experience_enquiry] = {
          'reference_number' => reference_number,
        }
        get :confirmation
      end

      it 'assigns the reference number' do
        expect(assigns(:reference_number)).to eq(reference_number)
      end

      it 'renders the confirmation page' do
        expect(response).to be_successful
      end
    end

    context 'when reference number is not present' do
      before do
        get :confirmation
      end

      it 'redirects to the start page' do
        expect(response).to redirect_to(product_experience_enquiry_form_path)
      end
    end
  end
end
