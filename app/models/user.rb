class User
  include ApiEntity

  set_singular_path 'user/users'

  attr_accessor :email, :chapter_ids, :stop_press_subscription

  def self.find(token)
    return nil if token.nil? && !Rails.env.development?

    super(nil, {}, headers(token))
  rescue Faraday::UnauthorizedError
    nil
  end

  def self.update(token, attributes)
    return nil if token.nil? && !Rails.env.development?

    json_api_params = {
      data: {
        attributes: attributes,
      },
    }
    super(json_api_params, headers(token))
  rescue Faraday::UnauthorizedError
    nil
  end

  def self.delete(token)
    return nil if token.nil? && !Rails.env.development?

    response = super(headers(token))
    response.status == 200
  rescue Faraday::UnauthorizedError
    false
  rescue Faraday::Error => e
    Rails.logger.error("Failed to delete user: #{e.message}")
    false
  end

  def self.headers(token)
    {
      authorization: "Bearer #{token}",
    }
  end
end
