module GreenLanes::FaqHelper
  def faq_categories
    t('green_lanes_faq.faq_categories').map do |key, category|
      {
        div_id: "category-heading-#{key.to_s.split('_').last}",
        heading: category[:heading],
        questions: category[:questions].map do |q_key, q_data|
          {
            div_id: "content-heading-#{key.to_s.split('_').last}",
            question: q_data[:question],
            answer: interpolate(q_data[:answer]),
            feedback_id: "#{key} | #{q_key}",
          }
        end,
      }
    end
  end

  def related_links
    t('green_lanes_faq.related_links').map do |_key, link|
      {
        link: interpolate(link),
      }
    end
  end

  private

  def interpolate(text)
    sprintf(text, green_lanes_start_path:)
  rescue KeyError => e
    Rails.logger.error("Missing interpolation key: #{e.message}")
    text
  end
end
