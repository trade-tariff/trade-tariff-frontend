require 'spec_helper'

RSpec.describe ProductExperience::EnquiryFormController, type: :controller do
  before do
    allow(controller).to receive(:set_path_info)

    routes.draw do
      namespace :product_experience, path: '', as: 'product_experience' do
        scope path: 'enquiry_form', as: 'enquiry_form', controller: 'enquiry_form' do
          get '/', action: 'show'
          get 'check_your_answers'
          post 'submit', action: 'submit_form', as: 'submit_form'
          get 'confirmation'
          get ':field', action: 'form'
          post ':field', action: 'submit'
        end
      end
    end

    allow(EnquiryFormHelper).to receive(:fields).and_return(%w[full_name email_address query])
  end

  describe 'GET #show' do
    it 'resets enquiry_data session' do
      get :show
      expect(session[:enquiry_data]).to eq({})
    end
  end

  describe 'GET #form' do
    it 'renders form for valid field' do
      get :form, params: { field: 'full_name' }
      expect(response).to render_template(:form)
    end

    it 'redirects on invalid field' do
      get :form, params: { field: 'unknown_field' }
      expect(response).to redirect_to(product_experience_enquiry_form_path)
    end
  end

  describe 'POST #submit' do
    context 'when required field is missing' do
      before do
        post :submit, params: { field: 'full_name', full_name: '' }
      end

      it 'sets flash full_name error' do
        expect(flash.now[:error]).to be_present
      end

      it 'renders form' do
        expect(response).to render_template(:form)
      end
    end

    context 'when email is invalid' do
      before do
        post :submit, params: { field: 'email_address', email_address: 'bad-email' }
      end

      it 'sets flash email_address error' do
        expect(flash.now[:error]).to eq('Please enter a valid email address.')
      end

      it 'renders form' do
        post :submit, params: { field: 'full_name', full_name: '' }
        expect(response).to render_template(:form)
      end
    end

    context 'when valid submission' do
      before do
        post :submit, params: { field: 'full_name', full_name: 'John Doe' }
      end

      it 'stores field' do
        expect(session[:enquiry_data]['full_name']).to eq('John Doe')
      end

      it 'redirects to next field' do
        expect(response).to redirect_to(controller: 'product_experience/enquiry_form', action: 'form', field: 'email_address')
      end
    end

    context 'when editing=true' do
      it 'redirects back to check_your_answers' do
        post :submit, params: { field: 'query', query: 'Some question?', editing: 'true' }
        expect(response).to redirect_to(product_experience_enquiry_form_check_your_answers_path)
      end
    end
  end

  describe 'GET #check_your_answers' do
    before do
      session[:enquiry_data] = { 'query' => 'Test question' }
      get :check_your_answers
    end

    it 'enquiry data is assigned' do
      expect(assigns(:enquiry_data)).to eq({ 'query' => 'Test question' })
    end

    it 'renders the page' do
      expect(response).to be_successful
    end
  end

  describe 'POST #submit_form' do
    it 'redirects to confirmation' do
      post :submit_form
      expect(response).to redirect_to(product_experience_enquiry_form_confirmation_path)
    end
  end

  describe 'GET #confirmation' do
    it 'renders confirmation page' do
      get :confirmation
      expect(response).to be_successful
    end
  end
end
