module Myott
  class MyottController < ApplicationController
    before_action :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote

  private

    def authenticate
      if current_user.nil?
        redirect_to(URI.join(TradeTariffFrontend.identity_base_url, '/myott').to_s, allow_other_host: true)
      end
    end

    def current_user
      @current_user ||= User.find(cookies[:id_token])
    end
    helper_method :current_user

    def current_subscription
      @current_subscription ||= Subscription.find(params[:id])
    end
  end
end
