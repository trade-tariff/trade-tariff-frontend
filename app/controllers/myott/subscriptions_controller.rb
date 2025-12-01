module Myott
  class SubscriptionsController < MyottController
    before_action :authenticate, except: %i[start invalid]

    def start; end

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
