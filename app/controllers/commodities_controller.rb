class CommoditiesController < GoodsNomenclaturesController
  helper_method :uk_declarable, :xi_declarable, :declarable

  def show
    session[:goods_nomenclature_code] = declarable.code

    @heading = declarable.heading
    @chapter = declarable.chapter
    @section = declarable.section

    if params[:country].present? && @search.geographical_area
      @rules_of_origin_schemes = declarable.rules_of_origin(params[:country])
    end
  rescue Faraday::ResourceNotFound
    @validity_periods = ValidityPeriod.all(Commodity, params[:id])
    @commodity_code = params[:id]
    @heading_code = params[:id].first(4)
    @chapter_code = params[:id].first(2)

    disable_search_form

    render :show_404, status: :not_found
  end

  private

  def declarable
    @declarable ||= heading? ? heading : commodity
  end

  def uk_declarable
    @uk_declarable ||= heading? ? uk_heading : uk_commodity
  end

  def xi_declarable
    return nil unless TradeTariffFrontend::ServiceChooser.xi?

    @xi_declarable ||= heading? ? xi_heading : xi_commodity
  end

  def heading
    TradeTariffFrontend::ServiceChooser.uk? ? uk_heading : xi_heading
  end

  def commodity
    TradeTariffFrontend::ServiceChooser.uk? ? uk_commodity : xi_commodity
  end

  def uk_heading
    @uk_heading ||= TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      HeadingPresenter.new(Heading.find(heading_id, query_params))
    end
  end

  def xi_heading
    @xi_heading ||= TradeTariffFrontend::ServiceChooser.with_source(:xi) do
      HeadingPresenter.new(Heading.find(heading_id, query_params))
    end
  end

  def uk_commodity
    fallback_to_nil_when_no_uk_equivalent = TradeTariffFrontend::ServiceChooser.xi?

    @uk_commodity ||= TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      CommodityPresenter.new(Commodity.find(params[:id], query_params))
    rescue Faraday::ResourceNotFound => e
      fallback_to_nil_when_no_uk_equivalent ? nil : raise(e)
    end
  end

  def xi_commodity
    @xi_commodity ||= TradeTariffFrontend::ServiceChooser.with_source(:xi) do
      CommodityPresenter.new(Commodity.find(params[:id], query_params))
    end
  end

  def query_params
    super.merge(filter: { meursing_additional_code_id: meursing_lookup_result.meursing_additional_code_id })
  end

  def heading?
    GoodsNomenclature.is_heading_id?(params[:id]) && heading&.declarable?
  end

  def heading_id
    params[:id].slice(0, 4)
  end
end
