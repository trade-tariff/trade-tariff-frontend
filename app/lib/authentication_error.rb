class AuthenticationError < StandardError
  attr_reader :reason

  def initialize(message, reason: nil)
    super(message)
    @reason = reason
  end

  def expired?
    reason == 'expired'
  end

  def should_clear_cookies?
    %w[not_in_group invalid_token missing_jwks_keys].include?(reason)
  end
end
