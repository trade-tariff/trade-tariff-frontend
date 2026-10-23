module Myott
  class SubscriptionsController < MyottController
    skip_before_action :authenticate, only: %i[start invalid]

    def start
      return @continue_url = myott_path if current_user.present?

      if safe_return_to.present?
        redirect_to "#{identity_url}?return_to=#{CGI.escape(safe_return_to)}", allow_other_host: true
        return
      end

      @continue_url = identity_url
    end

    def invalid
      redirect_to myott_path if current_user.present?
    end

    def index
      if safe_return_to.present?
        redirect_to safe_return_to, allow_other_host: false
        return
      end

      @stop_press = current_subscription('stop_press')
      @my_commodities = current_subscription('my_commodities')
    end

  private

    def safe_return_to
      return_to = params[:return_to].to_s
      return if return_to.blank?
      return unless return_to.start_with?('/subscriptions/') && !return_to.start_with?('//')

      return_to
    end
  end
end
