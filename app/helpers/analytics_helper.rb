# Logic must match cookie-manager.js
module AnalyticsHelper
  COOKIES_POLICY_NAME = 'cookies_policy'.freeze

  def analytics_allowed?
    if cookies[COOKIES_POLICY_NAME].nil?
      false
    else
      !!JSON.parse(cookies[COOKIES_POLICY_NAME]).fetch('usage', false)
    end
  end
end
