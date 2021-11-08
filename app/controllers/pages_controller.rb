class PagesController < ApplicationController
  before_action do
    @no_shared_search = true
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

  def tools
    @no_shared_search = true
  end

  def tariff_cookies
    render :cookies
  end

  def update_cookies
    if updated_cookies?
      cookies[:cookies_policy] = { value: policy_cookie_value, expires: Time.zone.now + 1.year }
    end

    render :cookies
  end

  private

  def policy_cookie_value
    value = { settings: true }
    value[:usage] = ga_tracking if ga_tracking
    value[:remember_settings] = remember_settings if remember_settings
    value.to_json
  end
end
