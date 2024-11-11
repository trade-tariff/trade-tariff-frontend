module GreenLanes
  class FetchGoodsNomenclature
    def initialize(params)
      @commodity_code = params[:commodity_code]
      @moving_date = params[:moving_date]
      @country_of_origin = params[:country_of_origin]
    end

    def call
      GreenLanes::GoodsNomenclature.find(
        @commodity_code,
        filter_params,
        authorization_header,
      )
    end

    private

    def filter_params
      {
        filter: {
          geographical_area_id: country_id,
          moving_date: @moving_date,
        },
        as_of: @moving_date,
      }
    end

    def authorization_header
      {
        authorization: TradeTariffFrontend.green_lanes_api_token,
      }
    end

    def country_id
      country = GreenLanes::CategoryAssessmentSearch.country_options.detect do |c|
        c.long_description == @country_of_origin
      end
      country&.geographical_area_id
    end
  end
end
