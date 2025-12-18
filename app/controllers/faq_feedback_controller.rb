class FaqFeedbackController < ApplicationController
  def index
    response = FaqFeedback.new.get_faq_feedback
    unless response
      Rails.logger.info('Feedback could not be fetched.')
    end
    render json: response
  end

  def create
    success = FaqFeedback.new.send_feedback_to_backend(feedback_params, session[:session_id])
    unless success
      Rails.logger.info('Feedback could not be sent.')
      # we're not letting the user know that the feedback was not sent
      # because they got around the session id constraint prior to the ajax request
    end
    success
  end

  private

  def feedback_params
    params.require(:faq_feedback).permit(:category_id, :question_id, :useful)
  end
end
