class FeedbackController < ApplicationController
  before_action do
    @tariff_last_updated = nil
  end

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if feedback.valid?
      FrontendMailer.new_feedback(feedback).deliver_now
      redirect_to action: :thanks
    else
      render :new
    end
  end

  def thanks; end

  private

  def feedback_params
    params.permit(:message, :name, :email)
  end
end
