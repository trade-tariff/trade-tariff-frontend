module Commodities
  class ChangesController < ::ChangesController
    private

    def commodity
      @commodity ||= Commodity.find(params[:commodity_id], query_params)
    end

    def changeable
      @changeable ||= CommodityPresenter.new(commodity)
    end

    def change_path(opts = {})
      commodity_path(commodity, opts)
    end
  end
end
