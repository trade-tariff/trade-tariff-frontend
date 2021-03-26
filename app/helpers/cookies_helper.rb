module CookiesHelper
  def policy_cookie
    cookie = cookies['cookies_policy']

    cookie.present? ? JSON.parse(cookie) : {}
  end

  def updated_cookies?
    ga_tracking || remember_settings
  end

  def usage_enabled?
    policy_cookie.fetch('usage', 'false') == 'true'
  end

  def remember_settings_enabled?
    policy_cookie.fetch('remember_settings', 'false') == 'true'
  end
end
