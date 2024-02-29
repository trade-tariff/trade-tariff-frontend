module GreenLanes
  class GoodsNomenclaturesController < ApplicationController
    def show
      @goods_nomenclature = GreenLanes::GoodsNomenclature.find(params[:id], query_params)
    end
  end
end
