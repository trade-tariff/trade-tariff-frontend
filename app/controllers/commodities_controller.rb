class CommoditiesController < GoodsNomenclaturesController
  helper_method :uk_commodity, :xi_commodity

  before_action :fetch_headings_or_commodities, only: %i[show]
  before_action :set_goods_nomenclature_code, only: %i[show]

  def show
    @heading = commodity.heading? ? commodity : commodity.heading
    @chapter = commodity.chapter
    @section = commodity.section

    if params[:country].present? && @search.geographical_area
      @rules_of_origin_schemes = commodity.rules_of_origin(params[:country])
    end
  end

  private

  def commodities_by_code
    search_term = Regexp.escape(params[:term].to_s)
    Commodity.by_code(search_term).sort_by(&:code)
  end

  def fetch_headings_or_commodities
    if heading_from_param&.declarable?
      fetch_headings
    else
      fetch_commodities
    end
  end

  def fetch_headings
    @commodities ||= {}

    if TradeTariffFrontend::ServiceChooser.uk?
      @commodities[:uk] = heading_from_param
      @commodities[:xi] = nil
    else
      @commodities[:xi] = heading_from_param
      @commodities[:uk] = TradeTariffFrontend::ServiceChooser.with_source(:uk) { heading_from_param }
    end
  end

  def heading_from_param
    @heading_from_param ||= if GoodsNomenclature.is_heading_id?(params[:id])
                              heading_id = params[:id].slice(0, 4)
                              HeadingPresenter.new(Heading.find(heading_id, query_params))
                            end
  end

  def fetch_commodities
    @commodities ||= {}

    if TradeTariffFrontend::ServiceChooser.uk?
      @commodities[:uk] = CommodityPresenter.new(Commodity.find(params[:id], query_params))
      @commodities[:xi] = nil
    else
      @commodities[:xi] = CommodityPresenter.new(Commodity.find(params[:id], query_params))
      @commodities[:uk] = TradeTariffFrontend::ServiceChooser.with_source(:uk) do
        CommodityPresenter.new(Commodity.find(params[:id], query_params))
      end
    end
  end

  def commodity
    @commodity ||= TradeTariffFrontend::ServiceChooser.uk? ? uk_commodity : xi_commodity
  end

  def xi_commodity
    @commodities[:xi]
  end

  def uk_commodity
    @commodities[:uk]
  end

  def set_goods_nomenclature_code
    session[:goods_nomenclature_code] = commodity.code
  end

  def query_params
    super.merge(filter: { meursing_additional_code_id: meursing_lookup_result.meursing_additional_code_id })
  end
end
