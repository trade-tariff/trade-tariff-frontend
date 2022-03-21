class FeedbackController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner,
                :disable_last_updated_footnote

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.valid?
      FrontendMailer.new_feedback(@feedback).deliver_now

      redirect_to :feedback_thanks
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
