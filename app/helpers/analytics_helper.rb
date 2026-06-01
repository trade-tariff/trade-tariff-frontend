# Logic must match cookie-manager.js
module AnalyticsHelper
  COOKIES_POLICY_NAME = 'cookies_policy'.freeze

  def analytics_allowed?
    cookie = cookies[COOKIES_POLICY_NAME]
    return false if cookie.nil?

    policy = JSON.parse(cookie)
    return false unless policy.is_a?(Hash)

    !!policy.fetch('usage', false)
  rescue JSON::ParserError
    false
  end
end
