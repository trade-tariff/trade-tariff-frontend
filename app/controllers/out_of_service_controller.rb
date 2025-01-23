class OutOfServiceController < ApplicationController
  def index
    render json: {
      "error": 'api-disabled',
      "message": 'The v1 API is deprecated. Please use the v2 API instead. https://api.trade-tariff.service.gov.uk/#gov-uk-trade-tariff-api',
    }, status: :service_unavailable
  end
end
