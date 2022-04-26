class CommoditiesController < GoodsNomenclaturesController
  rescue_from Faraday::ResourceNotFound, with: :show_validity_periods

  helper_method :uk_declarable, :xi_declarable, :declarable

  def show
    unless declarable.declarable?
      return redirect_to polymorphic_path(declarable)
    end

    session[:goods_nomenclature_code] = declarable.code

    @heading = declarable.heading
    @chapter = declarable.chapter
    @section = declarable.section

    if params[:country].present? && @search.geographical_area
      @rules_of_origin_schemes = declarable.rules_of_origin(params[:country])
    end
  end

  private

  def declarable
    @declarable ||= heading? ? heading : commodity_or_subheading
  end

  def uk_declarable
    @uk_declarable ||= begin
      heading? ? uk_heading : uk_commodity
    rescue Faraday::ResourceNotFound
      # When loading EU commodities we pull some measures from the UK commodity. If the UK commodity is not present
      # in the UK database, then we should show only the applicable EU measures and not render the 404 page.
      raise if TradeTariffFrontend::ServiceChooser.uk?
    end
  end

  def xi_declarable
    return nil unless TradeTariffFrontend::ServiceChooser.xi?

    @xi_declarable ||= heading? ? xi_heading : xi_commodity
  end

  def heading
    TradeTariffFrontend::ServiceChooser.uk? ? uk_heading : xi_heading
  end

  def commodity_or_subheading
    commodity
  rescue Faraday::ResourceNotFound
    subheading
  end

  def commodity
    TradeTariffFrontend::ServiceChooser.uk? ? uk_commodity : xi_commodity
  end

  def subheading
    Subheading.find("#{params[:id]}-80", query_params)
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
    @uk_commodity ||= TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      CommodityPresenter.new(Commodity.find(params[:id], query_params))
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
    GoodsNomenclature.is_heading_id?(params[:id])
  end

  def heading_id
    params[:id].slice(0, 4)
  end

  def show_validity_periods
    @validity_periods = ValidityPeriod.all(Commodity, params[:id])
    @commodity_code = params[:id]
    @heading_code = params[:id].first(4)
    @chapter_code = params[:id].first(2)

    disable_search_form

    render :show_404, status: :not_found
  rescue Faraday::ResourceNotFound
    find_relevant_goods_code_or_fallback
  end
end
