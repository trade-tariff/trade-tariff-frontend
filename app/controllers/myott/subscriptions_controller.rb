module Myott
  class SubscriptionsController < MyottController
    skip_before_action :authenticate, only: %i[start invalid]

    def start
      render :start_old and return unless TradeTariffFrontend.my_commodities?
    end

    def invalid
      redirect_to myott_path if current_user.present?
    end

    def index
      redirect_to myott_stop_press_path unless TradeTariffFrontend.my_commodities?

      @stop_press = current_subscription('stop_press')
      @my_commodities = current_subscription('my_commodities')
    end
  end
end
