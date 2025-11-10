class User
  include AuthenticatableApiEntity

  set_singular_path '/uk/user/users'

  attr_accessor :email, :chapter_ids, :stop_press_subscription

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
end
