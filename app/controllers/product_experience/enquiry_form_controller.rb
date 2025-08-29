module ProductExperience
  class EnquiryFormController < ApplicationController
    before_action :disable_switch_service_banner,
                  :disable_last_updated_footnote,
                  :disable_search_form,
                  :initialize_enquiry_data

    before_action :validate_field, except: %i[show check_your_answers submit_form confirmation]
    before_action :verify_submission_token, only: %i[submit submit_form]

    helper EnquiryFormHelper

    def show
      session[:enquiry_data] = {}
      session[:submission_token] = SecureRandom.uuid
    end

    def form
      @submission_token = session[:submission_token]
      @field = params[:field]
      @prev_field = previous_field(@field)
      render :form
    end

    def submit
      permitted = enquiry_params
      @field   = permitted[:field]
      value    = permitted[@field]
      editing  = permitted[:editing]

      if @field == 'query'
        add_query_to_cache(value)
      else
        session[:enquiry_data][@field] = value
      end

      validate_value(@field, value)
      return render :form if @alert.present?

      next_field_path_redirect(@field, editing:)
    end

    def submit_form
      session.delete(:submission_token)

      form_data = session[:enquiry_data].transform_keys(&:to_s)

      query_value = if form_data['query'].present?
                      Rails.cache.read(form_data['query'])
                    end

      attributes = {
        name: form_data['full_name'],
        company_name: form_data['company_name'],
        job_title: form_data['occupation'],
        email: form_data['email_address'],
        enquiry_category: form_data['category'],
        enquiry_description: query_value,
      }

      begin
        response = EnquiryForm.create!(attributes)

        if response['resource_id']
          Rails.cache.delete(form_data['query']) if form_data['query'].present?
          session.delete(:enquiry_data)
          session[:product_experience_enquiry] = {
            reference_number: response['resource_id'],
          }
          redirect_to product_experience_enquiry_form_confirmation_path
        else
          flash[:alert] = 'There was a problem submitting your enquiry. Please try again later.'
          redirect_to product_experience_enquiry_form_check_your_answers_path
        end
      rescue Faraday::Error
        flash[:alert] = 'There was a problem submitting your enquiry. Please try again later.'
        redirect_to product_experience_enquiry_form_check_your_answers_path
      end
    end

    def confirmation
      @reference_number = session.delete(:product_experience_enquiry)['reference_number'] if session[:product_experience_enquiry].present?
      redirect_to product_experience_enquiry_form_path if @reference_number.blank?
    end

    def check_your_answers
      @enquiry_data = session[:enquiry_data]

      if @enquiry_data['query'].present?
        @enquiry_data = @enquiry_data.merge(
          'query' => Rails.cache.read(@enquiry_data['query']),
        )
      end

      @prev_field = EnquiryFormHelper.fields.last
    end

    private

    def initialize_enquiry_data
      session[:enquiry_data] ||= {}
    end

    def verify_submission_token
      token_param = params[:submission_token]
      if token_param != session[:submission_token]
        redirect_to product_experience_enquiry_form_path
      end
    end

    def enquiry_params
      params.permit(
        :submission_token,
        :editing,
        :field,
        *EnquiryFormHelper.fields,
      )
    end

    def next_field_path_redirect(current, editing: false)
      if editing
        redirect_to product_experience_enquiry_form_check_your_answers_path and return
      end

      current_index = EnquiryFormHelper.fields.index(current)
      next_field = EnquiryFormHelper.fields[current_index + 1]

      if next_field
        redirect_to product_experience_enquiry_form_field_path(next_field)
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

    def add_query_to_cache(value)
      redis_key = "enquiry:query:#{session.id}"
      Rails.cache.write(redis_key, value, expires_in: 1.hour)
      session[:enquiry_data][@field] = redis_key
    end
  end
end
