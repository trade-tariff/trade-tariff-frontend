require 'json'

class CookiesConsentController < ApplicationController
  before_action :set_cookie_policy, only: %i[create]

  def create
    redirect_back(fallback_location: sections_path)
  end

  def add_seen_confirmation_message
    set_cookie_preference

    redirect_back(fallback_location: sections_path)
  end

  private

  def set_cookie_policy
    cookies[:cookies_policy] = { value: policy, expires: Time.zone.now + 1.year }
  end

  def set_cookie_preference
    cookies[:cookies_preferences_set] = { value: true, expires: Time.zone.now + 1.year }
  end

  def policy
    {
      settings: true,
      usage: cookies_enabled?,
      remember_settings: cookies_enabled?,
    }.to_json
  end

  def cookies_enabled?
    (params[:cookie_acceptance] == 'accept').to_s
  end
end
