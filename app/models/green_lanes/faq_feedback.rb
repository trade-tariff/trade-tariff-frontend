require 'api_entity'
module GreenLanes
  class FaqFeedback
    include ApiEntity

    def send_feedback_to_backend(feedback_params, session_id)
      response = self.class.post(
        '/api/v2/green_lanes/faq_feedback',
        data: {
          attributes: {
            session_id:,
            category_id: feedback_params[:category_id],
            question_id: feedback_params[:question_id],
            useful: feedback_params[:useful],
          },
        },
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => TradeTariffFrontend.green_lanes_api_token,
        },
      )

      if response.success?
        true
      else
        Rails.logger.warn("Failed to send feedback: #{response.status} #{response.body}")
        false
      end
    rescue StandardError => e
      Rails.logger.error("Unexpected error when sending feedback: #{e.message}")
      false
    end

    def get_faq_feedback
      response = self.class.get(
        '/api/v2/green_lanes/faq_feedback',
      )

      if response.success?
        response.body
      else
        Rails.logger.warn("Failed to get feedback: #{response.status} #{response.body}")
        nil
      end
    end
  end
end
