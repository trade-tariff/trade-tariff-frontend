module ProductExperience
  class EnquiryFormController < ApplicationController
    include EnquiryFormHelper

    before_action :disable_switch_service_banner,
                  :disable_search_form
    before_action :hide_feedback_useful_banner, except: :confirmation

    before_action :ensure_submission_started, except: %i[show confirmation]
    before_action :validate_field, only: %i[form submit]
    before_action :verify_submission_token, only: %i[submit submit_form]

    helper EnquiryFormHelper

    def show
      start_new_enquiry
      render_step('category')
    end

    def form
      render_step(params[:field])
    end

    def submit
      @field = params[:field]
      @enquiry_data = enquiry_data.merge(permitted_answers_for(@field))
      @errors = errors_for(@field, @enquiry_data)

      write_enquiry_data(@enquiry_data)

      if @errors.present?
        @alert = @errors.first[:message]
        @div_id = @errors.first[:field]
        @prev_field = previous_field(@field)
        render :form
      else
        next_field_path_redirect(@field, editing: params[:editing].present?, data: @enquiry_data)
      end
    end

    def check_your_answers
      @enquiry_data = enquiry_data
      @prev_field = 'contact_details'
    end

    def submit_form
      response = EnquiryForm.create!(submission_attributes)

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
      clear_enquiry_data
      session[:enquiry_form_draft_id] = SecureRandom.uuid
      session[:submission_token] = SecureRandom.uuid
      write_enquiry_data({})
    end

    def hide_feedback_useful_banner
      @hide_feedback_useful_banner = true
    end

    def ensure_submission_started
      return if session[:submission_token].present? && session[:enquiry_form_draft_id].present?

      redirect_to product_experience_enquiry_form_path
    end

    def render_step(field)
      @field = field
      @enquiry_data = enquiry_data
      @prev_field = previous_field(field)
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
      ProductExperience::EnquiryFormDraftStore.read(session[:enquiry_form_draft_id])
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
      params.slice(*permitted_fields).permit(*permitted_fields).to_h
    end

    def next_field_path_redirect(current, editing: false, data: enquiry_data)
      if editing
        redirect_to product_experience_enquiry_form_check_your_answers_path and return
      end

      next_field = next_field(current, data)

      if next_field
        redirect_to product_experience_enquiry_form_field_path(next_field)
      else
        redirect_to product_experience_enquiry_form_check_your_answers_path
      end
    end

    def next_field(current, data = enquiry_data)
      case current
      when 'category'
        field_value('category', data) == 'classification' ? 'goods_details' : 'query'
      when 'goods_details'
        'commodity_code'
      when 'commodity_code', 'query'
        'contact_details'
      end
    end

    def previous_field(current)
      case current
      when 'goods_details', 'query'
        'category'
      when 'commodity_code'
        'goods_details'
      when 'contact_details'
        field_value('category', enquiry_data) == 'classification' ? 'commodity_code' : 'query'
      end
    end

    def errors_for(field, data)
      case field
      when 'category'
        category_errors(data)
      when 'goods_details'
        goods_detail_errors(data)
      when 'commodity_code'
        commodity_code_errors(data)
      when 'query'
        query_errors(data)
      when 'contact_details'
        contact_detail_errors(data)
      else
        []
      end
    end

    def category_errors(data)
      errors = []
      errors << error('category', 'Please select what you need help with.') if data['category'].blank?
      errors << error('other_category', 'Please add a short label.') if data['category'] == 'other' && data['other_category'].blank?
      errors
    end

    def goods_detail_errors(data)
      errors = []
      errors << error('goods_product', 'Please describe the product.') if data['goods_product'].blank?
      errors << error('goods_made_of', 'Please say what the product is made of.') if data['goods_made_of'].blank?
      errors
    end

    def commodity_code_errors(data)
      errors = []
      errors << error('has_commodity_code', 'Please select whether you have a possible commodity code.') if data['has_commodity_code'].blank?
      errors << error('commodity_code', 'Please enter the possible commodity code.') if data['has_commodity_code'] == 'yes' && data['commodity_code'].blank?
      errors
    end

    def query_errors(data)
      errors = []
      errors << error('query', 'Please explain how we can help.') if data['query'].blank?
      errors << error('query', 'You can enter up to 5,000 characters.') if text_too_long?(data['query'], 5000)
      errors
    end

    def contact_detail_errors(data)
      errors = []
      errors << error('email_address', 'Please enter your email address.') if data['email_address'].blank?
      if data['email_address'].present? && !data['email_address'].match?(URI::MailTo::EMAIL_REGEXP)
        errors << error('email_address', 'Please enter a valid email address.')
      end
      errors
    end

    def error(field, message)
      { field:, message: }
    end

    def submission_attributes
      data = enquiry_data

      {
        name: data['full_name'],
        company_name: data['company_name'],
        job_title: data['occupation'],
        email: data['email_address'],
        enquiry_category: data['category'],
        enquiry_description: data['query'],
        other_category: data['other_category'],
        goods_product: data['goods_product'],
        goods_made_of: data['goods_made_of'],
        goods_used_for: data['goods_used_for'],
        goods_function: data['goods_function'],
        goods_processed: data['goods_processed'],
        goods_packaged: data['goods_packaged'],
        has_commodity_code: data['has_commodity_code'],
        commodity_code: data['commodity_code'],
      }.compact
    end
  end
end
