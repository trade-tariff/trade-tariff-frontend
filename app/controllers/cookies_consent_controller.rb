require 'json'

class CookiesConsentController < ApplicationController
  def self.get_cookie_policy_value(cookie)
    unless cookie.nil?
      JSON.parse(cookie)['settings']
    end
  end

  def accept_cookies
    set_cookie_policy(true)
    redirect_back(fallback_location: root_path)
  end

  def reject_cookies
    set_cookie_policy(false)
    redirect_back(fallback_location: root_path)
  end

  def add_seen_confirmation_message
    set_cookie_preference
    redirect_back(fallback_location: root_path)
  end

  private

  def set_cookie_policy(should_accept)
    policy = "{ \"settings\": \"#{should_accept}\", \"usage\": \"#{should_accept}\", \"hasSeen\": \"false\"
      }"
    cookies[:cookies_policy] = { value: policy, expires: Time.zone.now + 3600 }
  end

  def set_cookie_preference
    cookies[:cookies_preferences_set] = { value: true, expires: Time.zone.now + 3600 }
  end
end
