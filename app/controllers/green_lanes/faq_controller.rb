module GreenLanes
  class FaqController < ApplicationController
    # application contoller requires search params to be set
    # override this for faq feedback ajax requests
    skip_before_action :set_search, only: [:send_feedback]
    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def index; end

    def send_feedback
      success = FaqFeedback.new.send_feedback_to_backend(feedback_params, session[:session_id])
      unless success
        Rails.logger.info('Feedback could not be sent.')
        # we're not letting the user know that the feedback was not sent
        # because they got around the session id constraint prior to the ajax request
      end
      success
    end

    def get_feedback
      response = FaqFeedback.new.get_faq_feedback
      unless response
        Rails.logger.info('Feedback could not be fetched.')
      end
      render json: response
    end

    private

    def feedback_params
      params.require(:faq_feedback).permit(:category_id, :question_id, :useful)
    end
  end
end
