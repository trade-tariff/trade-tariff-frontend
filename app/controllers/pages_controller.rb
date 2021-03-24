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
    remember_settings = params['cookie_remember_settings']
    ga_tracking = params['cookie_consent_usage']

    unless remember_settings.nil? || ga_tracking.nil?
      set_cookie_policy(ga_tracking, remember_settings)
    end
  end

  private

  def set_cookie_policy(ga_tracking, remembers_settings)
    policy = "{ \"settings\": \"true\", \"usage\": \"#{ga_tracking}\", \"remember_settings\": \"#{remembers_settings}\"}"
    cookies[:cookies_policy] = {value: policy, expires: Time.zone.now + 3600}
  end
end
