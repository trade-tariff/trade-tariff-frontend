class CommoditiesController < GoodsNomenclaturesController
  before_action :fetch_commodity_from_xi,
                :fetch_commodity_from_uk,
                only: %i[show]

  def show
    @heading = commodity.heading
    @chapter = commodity.chapter
    @section = commodity.section
    @back_path = request.referer || heading_path(@heading.short_code)
    commodity.prev, commodity.next = set_prev_next(commodity)
  end

  private

  def commodities_by_code
    search_term = Regexp.escape(params[:term].to_s)
    Commodity.by_code(search_term).sort_by(&:code)
  end

  def set_prev_next(commodity)
    gnids = Heading.find(commodity.heading.short_code, query_params)
                   .commodities.select(&:leaf?)
                   .map(&:goods_nomenclature_item_id)
    return [nil, nil] unless i = gnids.index(commodity.goods_nomenclature_item_id)

    [
      i == 0 ? nil : Commodity.find(gnids[i-1]),
      i == (gnids.length - 1) ? nil : Commodity.find(gnids[i+1])
    ]
  end

  def fetch_commodity_from_xi
    @xi_commodity = TradeTariffFrontend::ServiceChooser.with_source(:xi) do
      CommodityPresenter.new(Commodity.find(params[:id], query_params))
    end
  end

  def fetch_commodity_from_uk
    @uk_commodity = TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      CommodityPresenter.new(Commodity.find(params[:id], query_params))
    end
  end

  def commodity
    @commodity ||= TradeTariffFrontend::ServiceChooser.uk? ? @uk_commodity : @xi_commodity
  end
end
