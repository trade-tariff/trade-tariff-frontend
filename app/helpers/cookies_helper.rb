module CookiesHelper
  def policy_cookie
    cookie = cookies['cookies_policy']

    cookie.present? ? JSON.parse(cookie) : {}
  end

  def preference_cookie
    cookies['cookies_preferences_set']
  end

  def cookies_set?
    policy_cookie.present? && preference_cookie.present?
  end

  def updated_cookies?
    ga_tracking || remember_settings
  end

  def usage_enabled?
    policy_cookie['usage'] == 'true'
  end

  def usage_disabled?
    policy_cookie['usage'] == 'false'
  end

  def remember_settings_enabled?
    policy_cookie['remember_settings'] == 'true'
  end

  def remember_settings_disabled?
    policy_cookie['remember_settings'] == 'false'
  end

  private

  def remember_settings
    policy_cookie_param_for('cookie_remember_settings')
  end

  def ga_tracking
    policy_cookie_param_for('cookie_consent_usage')
  end

  def policy_cookie_param_for(key)
    setting = params[key]

    return nil if setting.blank?

    setting
  end
end
