module Myott
  class SubscriptionsController < MyottController
    skip_before_action :authenticate, only: %i[start invalid]

    def start
      @continue_url = if current_user.present?
                        myott_path
                      else
                        URI.join(TradeTariffFrontend.identity_base_url, '/myott').to_s
                      end
    end

    def invalid
      redirect_to myott_path if current_user.present?
    end

    def index
      @stop_press = current_subscription('stop_press')
      @my_commodities = current_subscription('my_commodities')
    end
  end
end
