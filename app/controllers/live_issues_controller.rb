class LiveIssuesController < ApplicationController
  before_action :disable_switch_service_banner,
                :disable_search_form

  def index
    render :index
  end
end
