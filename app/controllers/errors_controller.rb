class ErrorsController < ApplicationController
  skip_before_action :set_last_updated
  skip_before_action :set_path_info
  skip_before_action :set_search
  skip_before_action :bots_no_index_if_historical

  before_action :disable_search_form, :disable_switch_service_banner

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end

  def maintenance
    render status: :service_unavailable
  end
end
