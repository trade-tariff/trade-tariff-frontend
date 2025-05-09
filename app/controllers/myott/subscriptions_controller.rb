module Myott
  class SubscriptionsController < MyottController
    before_action :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote

    def dashboard
      @email = current_user&.fetch('email') || 'not_logged_in@email.com'
    end
  end
end
