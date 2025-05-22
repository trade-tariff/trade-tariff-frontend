module Myott
  class MyottController < ApplicationController
    before_action :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote

  private

    def current_user
      @current_user ||= User.find(cookies[:id_token])
    end
  end
end
