module Myott
  class SubscriptionsController < ApplicationController
    before_action :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote

    def dashboard
      @email = 'test@email.com'
    end
  end
end
