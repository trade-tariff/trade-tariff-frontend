class LiveIssuesController < ApplicationController
  before_action :disable_switch_service_banner

  def index
    render :index
  end
end
