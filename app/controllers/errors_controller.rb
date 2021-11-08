class ErrorsController < ApplicationController
  before_action do
    @no_shared_search = true
    @tariff_last_updated = nil
  end

  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end

  def maintenance
    render status: 503
  end
end
