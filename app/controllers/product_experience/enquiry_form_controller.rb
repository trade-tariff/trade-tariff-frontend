module ProductExperience
  class EnquiryFormController < ApplicationController
    include EnquiryFormHelper

    before_action :disable_switch_service_banner,
                  :disable_search_form
    before_action :hide_feedback_useful_banner, except: :confirmation

    before_action :ensure_submission_started, except: %i[show confirmation]
    before_action :validate_field, only: %i[form submit]
    before_action :verify_submission_token, only: %i[submit submit_form]

    def show
      start_new_enquiry
      render_step('category')
    end

    def form
      render_step(params[:field])
    end

    def submit
      @field = params[:field]
      previous_data = enquiry_data
      @enquiry_data = ProductExperience::EnquiryFormJourney.normalized_data(
        @field,
        previous_data,
        permitted_answers_for(@field),
      )
      @errors = ProductExperience::EnquiryFormValidator.errors_for(@field, @enquiry_data)

      write_enquiry_data(@enquiry_data)

      if @errors.present?
        @alert = @errors.first[:message]
        @div_id = @errors.first[:field]
        @prev_field = ProductExperience::EnquiryFormJourney.previous_field(@field, @enquiry_data)
        render :form
      else
        next_field_path_redirect(
          @field,
          editing: params[:editing].present?,
          data: @enquiry_data,
          previous_data:,
        )
      end
    end

    def check_your_answers
      @enquiry_data = enquiry_data
      redirect_to_first_incomplete_field(@enquiry_data) and return

      @prev_field = 'contact_details'
    end

    def submit_form
      data = enquiry_data
      redirect_to_first_incomplete_field(data) and return

      response = EnquiryForm.create!(submission_attributes(data))

      if response['resource_id'].present?
        clear_enquiry_data
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

    def confirmation
      enquiry = session.delete(:product_experience_enquiry).to_h
      @reference_number = enquiry['reference_number'] || enquiry[:reference_number]
      redirect_to product_experience_enquiry_form_path if @reference_number.blank?
    end

    private

    def start_new_enquiry
      session.delete(:product_experience_enquiry)
      clear_enquiry_data
      session[:enquiry_form_draft_id] = SecureRandom.uuid
      session[:submission_token] = SecureRandom.uuid
      write_enquiry_data({})
    end

    def hide_feedback_useful_banner
      @hide_feedback_useful_banner = true
    end

    def search_attributes
      {}
    end

    def ensure_submission_started
      if session[:submission_token].present? &&
          session[:enquiry_form_draft_id].present? &&
          ProductExperience::EnquiryFormDraftStore.exists?(session[:enquiry_form_draft_id])
        return
      end

      if session[:enquiry_form_draft_id].present?
        Rails.logger.warn "Missing enquiry form draft for session draft id #{session[:enquiry_form_draft_id]}"
      end

      clear_enquiry_data

      redirect_to product_experience_enquiry_form_path
    end

    def render_step(field)
      @field = field
      @enquiry_data = enquiry_data
      @prev_field = ProductExperience::EnquiryFormJourney.previous_field(field, @enquiry_data)
      render :form
    end

    def verify_submission_token
      return if params[:submission_token] == session[:submission_token]

      redirect_to product_experience_enquiry_form_path
    end

    def validate_field
      return if EnquiryFormHelper.fields.include?(params[:field])

      Rails.logger.warn "Invalid enquiry form field: #{params[:field]}"
      redirect_to product_experience_enquiry_form_path
    end

    def enquiry_data
      ProductExperience::EnquiryFormDraftStore.read(session[:enquiry_form_draft_id]).to_h
    end

    def write_enquiry_data(data)
      ProductExperience::EnquiryFormDraftStore.write(session[:enquiry_form_draft_id], data)
    end

    def clear_enquiry_data
      ProductExperience::EnquiryFormDraftStore.delete(session[:enquiry_form_draft_id])
      session.delete(:enquiry_form_draft_id)
      session.delete(:submission_token)
    end

    def permitted_answers_for(field)
      permitted_fields = EnquiryFormHelper::FIELD_PARAMS.fetch(field)
      permitted_fields.each_with_object({}) do |param, answers|
        answers[param] = params[param].to_s if params.key?(param)
      end
    end

    def next_field_path_redirect(current, editing: false, data: enquiry_data, previous_data: enquiry_data)
      if editing && !ProductExperience::EnquiryFormJourney.continue_journey_after_edit?(current, previous_data, data)
        redirect_to product_experience_enquiry_form_check_your_answers_path and return
      end

      next_field = ProductExperience::EnquiryFormJourney.next_field(current, data)

      if next_field
        redirect_to product_experience_enquiry_form_field_path(next_field)
      else
        redirect_to product_experience_enquiry_form_check_your_answers_path
      end
    end

    def redirect_to_first_incomplete_field(data)
      field = first_incomplete_field(data)
      return false if field.blank?

      redirect_to product_experience_enquiry_form_field_path(field)
    end

    def first_incomplete_field(data)
      ProductExperience::EnquiryFormJourney.active_fields(data).find do |field|
        ProductExperience::EnquiryFormValidator.errors_for(field, data).present?
      end
    end

    def submission_attributes(data = enquiry_data)
      common_attributes = {
        name: data['full_name'],
        company_name: data['company_name'],
        job_title: data['occupation'],
        email: data['email_address'],
        enquiry_category: data['category'],
      }
      common_attributes[:other_category] = data['other_category'] if data['category'] == 'other'

      route_attributes =
        if data['category'] == 'classification'
          classification_submission_attributes(data)
        else
          {
            enquiry_description: data['query'],
          }
        end

      common_attributes.merge(route_attributes).compact
    end

    def classification_submission_attributes(data)
      attributes = {
        goods_product: data['goods_product'],
        goods_made_of: data['goods_made_of'],
        goods_used_for: data['goods_used_for'],
        goods_function: data['goods_function'],
        goods_processed: data['goods_processed'],
        goods_packaged: data['goods_packaged'],
        has_commodity_code: data['has_commodity_code'],
      }
      attributes[:commodity_code] = data['commodity_code'] if data['has_commodity_code'] == 'yes'
      attributes
    end
  end
end
