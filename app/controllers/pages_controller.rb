class PagesController < ApplicationController
  before_action do
    @tariff_last_updated = nil
  end

  def index
    @section_css = 'govuk-visually-hidden'
    @meta_description = I18n.t('meta_description')
  end

  def opensearch
    respond_to do |format|
      format.xml
    end
  end

  def robots
    respond_to :text
    expires_in 6.hours, public: true
  end

  def tools
    @no_shared_search = true
    @no_shared_switch_service_link = true
  end

  def update_cookies
    if ga_tracking || remember_settings
      cookies[:cookies_policy] = { value: policy_cookie_value, expires: Time.zone.now + 1.year }
    end
  end

  private

  def policy_cookie_value
    value = { settings: true }
    value[:usage] = ga_tracking if ga_tracking
    value[:remember_settings] = remember_settings if remember_settings
    value.to_json
  end

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
