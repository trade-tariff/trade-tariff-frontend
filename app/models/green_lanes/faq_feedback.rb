require 'api_entity'
module GreenLanes
  class FaqFeedback
    include XiOnlyApiEntity
    include ApiEntity

    def send_feedback_to_backend(feedback_params, session_id)
      response = self.class.post(
        'green_lanes/faq_feedback',
        {
          data: {
            attributes: {
              session_id:,
              category_id: feedback_params[:category_id],
              question_id: feedback_params[:question_id],
              useful: feedback_params[:useful],
            },
          },
        }.to_json,
        headers,
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
        'green_lanes/faq_feedback',
        {},
        headers,
      )

      if response.success?
        response.body
      else
        Rails.logger.warn("Failed to get feedback: #{response.status} #{response.body}")
        nil
      end
    end

    def headers
      {
        'Accept' => ClientBuilder::ACCEPT,
        'Content-Type' => 'application/json',
        authorization: TradeTariffFrontend.green_lanes_api_token,
      }
    end
  end
end
