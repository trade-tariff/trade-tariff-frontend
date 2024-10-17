module GreenLanes
  class ValidateDeclarableGoodsNomenclature
    def initialize(params)
      @params = params
    end

    def call
      goods_nomenclature = ::GoodsNomenclature.find(@params[:commodity_code], { as_of: @params[:moving_date] })
      raise Faraday::ResourceNotFound unless goods_nomenclature.declarable
    end
  end
end
