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

      if value.blank? && required_field?(@field)
        flash.now[:error] = error_message_for(@field)
        return render :form
      end

      if @field == 'email_address' && !value.match?(URI::MailTo::EMAIL_REGEXP)
        flash.now[:error] = 'Please enter a valid email address.'
        return render :form
      end

      session[:enquiry_data][@field] = value
      redirect_to next_field_path(@field)
    end

    def submit_form
      Rails.logger.info "Submitting form with data: #{session[:enquiry_data].inspect}"
      redirect_to product_experience_enquiry_form_confirmation_path
    end

    def confirmation; end

    def check_your_answers
      @enquiry_data = session[:enquiry_data]
      @prev_field = EnquiryFormHelper::FIELDS.last
    end

    private

    def initialize_enquiry_data
      session[:enquiry_data] ||= {}
    end

    def next_field_path(current)
      current_index = EnquiryFormHelper::FIELDS.index(current)
      next_field = EnquiryFormHelper::FIELDS[current_index + 1]

      if next_field
        url_for(controller: 'product_experience/enquiry_form', action: 'form', field: next_field)
      else
        product_experience_enquiry_form_check_your_answers_path
      end
    end

    def validate_field
      if EnquiryFormHelper::FIELDS.exclude?(params[:field])
        Rails.logger.warn "Invalid field: #{params[:field]}"
        redirect_to product_experience_enquiry_form_path
      end
    end

    def previous_field(current)
      current_index = EnquiryFormHelper::FIELDS.index(current)
      prev_field = EnquiryFormHelper::FIELDS[current_index - 1] if current_index && current_index.positive?

      prev_field
    end
  end
end
