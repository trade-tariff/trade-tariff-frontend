module Myott
  class MyottController < ApplicationController
    before_action :authenticate,
                  :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote

    rescue_from AuthenticationError, with: :handle_authentication_error

  private

    def authenticate
      if current_user.nil?
        session[:myott_return_url] = request.fullpath
        redirect_to(URI.join(TradeTariffFrontend.identity_base_url, '/myott').to_s, allow_other_host: true)
      elsif session[:myott_return_url]
        redirect_to(session.delete(:myott_return_url))
      end
    end

    def handle_authentication_error(error)
      clear_authentication_cookies if error.should_clear_cookies?

      session[:myott_return_url] = request.fullpath
      redirect_to(URI.join(TradeTariffFrontend.identity_base_url, '/myott').to_s, allow_other_host: true)
    end

    def clear_authentication_cookies
      cookies.delete(id_token_cookie_name, domain: TradeTariffFrontend.identity_cookie_domain)
      cookies.delete(refresh_token_cookie_name, domain: TradeTariffFrontend.identity_cookie_domain)
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
      cookies[id_token_cookie_name]
    end

    def id_token_cookie_name
      TradeTariffFrontend.id_token_cookie_name
    end

    def refresh_token_cookie_name
      TradeTariffFrontend.refresh_token_cookie_name
    end

    def get_subscription(subscription_type)
      subscription_id = current_user[:subscriptions]&.find { |s| s['subscription_type'] == subscription_type && s['active'] }&.fetch('id', nil)
      Subscription.find(subscription_id, user_id_token) if subscription_id
    end
  end
end
