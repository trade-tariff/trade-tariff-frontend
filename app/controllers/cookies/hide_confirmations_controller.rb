module Cookies
  class HideConfirmationsController < ApplicationController
    def create
      cookies[:cookies_preferences_set] = {
        value: true,
        expires: 1.year.from_now,
      }

      redirect_back(fallback_location: home_path)
    end
  end
end
