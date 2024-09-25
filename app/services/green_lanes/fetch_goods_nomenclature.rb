module GreenLanes
  class FetchGoodsNomenclature
    def initialize(params)
      @params = params
    end

    def call
      GreenLanes::GoodsNomenclature.find(
        @params[:commodity_code],
        {
          filter: {
            geographical_area_id: @params[:country_of_origin],
            moving_date: @params[:moving_date],
          },
          as_of: @params[:moving_date],
        },
        {
          authorization: TradeTariffFrontend.green_lanes_api_token,
        },
      )

      # goods_nomenclature.get_declarable
    end
  end
end
