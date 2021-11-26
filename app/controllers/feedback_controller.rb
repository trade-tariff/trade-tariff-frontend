class FeedbackController < ApplicationController
  before_action do
    @tariff_last_updated = nil
  end

  def new; end

  def create
    feedback = Feedback.new(feedback_params)

    if feedback.valid?
      FrontendMailer.new_feedback(feedback).deliver_now
      status = :ok
      flash[:alert] = 'Thanks you for your feedback.'
    else
      flash[:alert] = 'Something went wrong.'
      status = :unprocessable_entity
    end

    if request.xhr?
      head status
    else
      redirect_to action: :thanks
    end
  end

  def thanks; end

  private

  def feedback_params
    params.permit(:message, :name, :email)
  end
end
