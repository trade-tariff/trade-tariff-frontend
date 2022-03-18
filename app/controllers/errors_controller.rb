class ErrorsController < ApplicationController
  before_action :disable_last_updated_footnote

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
