class FeedbackController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner,
                :disable_last_updated_footnote

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.authenticity_token = params[:authenticity_token]

    if @feedback.valid?
      FrontendMailer.new_feedback(@feedback).deliver_now
      @feedback.record_delivery!

      redirect_to feedback_thanks_path
    else
      render :new
    end
  end

  def thanks; end

  private

  def feedback_params
    params.require(:feedback).permit(:name, :email, :message)
  end
end
