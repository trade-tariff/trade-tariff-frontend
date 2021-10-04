class CommoditiesController < GoodsNomenclaturesController
  helper_method :uk_commodity, :xi_commodity

  before_action :fetch_commodities, only: %i[show]
  before_action :set_session, only: %i[show]

  def show
    @heading = commodity.heading
    @chapter = commodity.chapter
    @section = commodity.section
    @back_path = request.referer || heading_path(@heading.short_code)

    if TradeTariffFrontend.rules_of_origin_api_requests_enabled? &&
        params[:country].present? && @search.geographical_area

      @rules_of_origin = commodity.rules_of_origin(params[:country])
    end
  end

  private

  def commodities_by_code
    search_term = Regexp.escape(params[:term].to_s)
    Commodity.by_code(search_term).sort_by(&:code)
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

  def set_session
    session[:declarable_code] = commodity.code
  end

  def query_params
    super.merge(filter: { meursing_additional_code_id: meursing_lookup_result.meursing_additional_code_id })
  end
end
