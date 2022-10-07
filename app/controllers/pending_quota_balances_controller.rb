class PendingQuotaBalancesController < ApplicationController
  def show
    pqb = PendingQuotaBalanceService.new(params[:commodity_id], params[:order_number], @search.date)

    render json: pqb.call
  end
end
