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
      @current_user ||= User.find(nil, user_id_token)
    end
    helper_method :current_user

    def current_subscription(subscription_type)
      @current_subscriptions ||= {}
      @current_subscriptions[subscription_type] ||= get_subscription(subscription_type)
    end

    helper_method :current_subscription

    def user_id_token
      cookies[:id_token]
    end

    def get_subscription(subscription_type)
      subscription_id = current_user[:subscriptions]&.find { |s| s['subscription_type'] == subscription_type && s['active'] }&.fetch('id', nil)
      Subscription.find(subscription_id, user_id_token) if subscription_id
    end
  end
end
