class User
  include ApiEntity

  set_singular_path 'user/users'

  attr_accessor :email, :chapter_ids, :stop_press_subscription

  def self.find(token)
    return nil if token.nil?

    super(nil, {}, headers(token))
  rescue Faraday::UnauthorizedError
    nil
  end

  def self.headers(token)
    {
      authorization: "Bearer #{token}",
    }
  end
end
