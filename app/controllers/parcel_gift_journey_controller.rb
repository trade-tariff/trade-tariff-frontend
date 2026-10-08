class ParcelGiftJourneyController < ApplicationController
  delegate :service_name, to: TradeTariffFrontend::ServiceChooser, private: true

  before_action :set_review_headers,
                :require_journey,
                :disable_search_form,
                :disable_switch_service_banner

  def new
    @form = choice_form(submitted_choice)
    return unless params.key?(:parcel_gift_choice_form)

    if @form.valid?
      redirect_to public_send("#{@form.selected_step.route_name}_path"), status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @step = @journey.find_step(request.path_parameters[:step_id], service_name:)
    head :not_found unless @step
  end

  private

  def set_review_headers
    response.headers['X-Robots-Tag'] = 'noindex, nofollow'
  end

  def require_journey
    @journey = Rails.configuration.parcel_gift_journey
    head :not_found unless parcel_gift_journey_enabled? && @journey.chooser.services.include?(service_name)
  end

  def choice_form(choice = nil)
    ParcelGiftChoiceForm.new(journey: @journey, service_name:, choice:)
  end

  def submitted_choice
    values = params[:parcel_gift_choice_form]
    return unless values.is_a?(ActionController::Parameters)

    value = values[:choice]
    value if value.is_a?(String)
  end
end
