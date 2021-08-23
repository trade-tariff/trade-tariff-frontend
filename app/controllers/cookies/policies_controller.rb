module Cookies
  class PoliciesController < ApplicationController
    before_action { @no_shared_search = true }

    def show
      @policy = cookies_policy
    end

    def create
      @policy = cookies_policy
      @policy.attributes = policy_params

      cookies[:cookies_policy] = {
        value: @policy.to_cookie,
        expires: 1.year.from_now,
      }
      @policy.mark_persisted!

      if policy_params.key? :acceptance
        redirect_back(fallback_location: sections_path)
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
