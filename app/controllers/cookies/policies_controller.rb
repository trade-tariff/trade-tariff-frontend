module Cookies
  class PoliciesController < ApplicationController
    before_action :disable_search_form

    def show; end

    def create
      cookies_policy.attributes = policy_params

      cookies[:cookies_policy] = {
        value: cookies_policy.to_cookie,
        expires: 1.year.from_now,
      }
      cookies_policy.mark_persisted!

      if policy_params.key? :acceptance
        redirect_back(fallback_location: home_path)
      else
        @saved = true
        render :show
      end
    end
    alias_method :update, :create

  private

    def policy_params
      params
        .fetch(:cookies_policy, {}) # allow for users just hitting save
        .permit(:usage, :remember_settings, :acceptance)
    end
  end
end
