module ProductExperience
  class EnquiryFormController < ApplicationController
    before_action :disable_switch_service_banner,
                  :disable_last_updated_footnote,
                  :disable_search_form,
                  :initialize_enquiry_data

    before_action :validate_field, except: %i[show check_your_answers submit_form confirmation]

    helper EnquiryFormHelper

    def show
      session[:enquiry_data] = {}
    end

    def form
      @field = params[:field]
      @prev_field = previous_field(@field)
      render :form
    end

    def submit
      @field = params[:field]
      value = params[@field]
      editing = params[:editing]

      if value.blank? && required_field?(@field)
        flash.now[:error] = error_message_for(@field)
        return render :form
      end

      if @field == 'email_address' && !value.match?(URI::MailTo::EMAIL_REGEXP)
        flash.now[:error] = 'Please enter a valid email address.'
        return render :form
      end

      session[:enquiry_data][@field] = value
      next_field_path_redirect(@field, editing: editing)
    end

    def submit_form
      if params[:submission_token] != session[:submission_token]
        return redirect_to product_experience_enquiry_form_path
      end

      session.delete(:submission_token)

      form_data = session[:enquiry_data].transform_keys(&:to_s)

      attributes = {
        name: form_data['full_name'],
        company_name: form_data['company_name'],
        job_title: form_data['occupation'],
        email: form_data['email_address'],
        enquiry_category: form_data['category'],
        enquiry_description: form_data['query'],
      }

      begin
        response = EnquiryForm.create!(attributes)

        if response['reference_number']
          session.delete(:enquiry_data)
          redirect_to product_experience_enquiry_form_confirmation_path(reference_number: response['reference_number'])
        else
          flash[:error] = 'There was a problem submitting your enquiry. Please try again later.'
          redirect_to product_experience_enquiry_form_check_your_answers_path
        end
      rescue Faraday::Error
        flash[:error] = 'There was a problem submitting your enquiry. Please try again later.'
        redirect_to product_experience_enquiry_form_check_your_answers_path
      end
    end

    def confirmation
      @reference_number = params[:reference_number]
    end

    def check_your_answers
      session[:submission_token] = SecureRandom.uuid # ensures user can't submit_form multiple times
      @enquiry_data = session[:enquiry_data]
      @prev_field = EnquiryFormHelper.fields.last
    end

    private

    def initialize_enquiry_data
      session[:enquiry_data] ||= {}
    end

    def next_field_path_redirect(current, editing: false)
      if editing
        redirect_to product_experience_enquiry_form_check_your_answers_path and return
      end

      current_index = EnquiryFormHelper.fields.index(current)
      next_field = EnquiryFormHelper.fields[current_index + 1]

      if next_field
        redirect_to controller: 'product_experience/enquiry_form', action: 'form', field: next_field

      else
        redirect_to product_experience_enquiry_form_check_your_answers_path
      end
    end

    def validate_field
      if EnquiryFormHelper.fields.exclude?(params[:field])
        Rails.logger.warn "Invalid field: #{params[:field]}"
        redirect_to product_experience_enquiry_form_path
      end
    end

    def previous_field(current)
      current_index = EnquiryFormHelper.fields.index(current)
      prev_field = EnquiryFormHelper.fields[current_index - 1] if current_index && current_index.positive?

      prev_field
    end
  end
end
