class CommoditiesController < GoodsNomenclaturesController
  rescue_from Faraday::ResourceNotFound, with: :show_validity_periods

  helper_method :uk_declarable, :xi_declarable, :declarable

  def show
    unless declarable.declarable?
      return redirect_to polymorphic_path(declarable)
    end

    @heading = declarable.heading
    @chapter = declarable.chapter
    @section = declarable.section
    if declarable.has_chemicals?
      @all_chemicals = ChemicalSubstance.by_sid(declarable.resource_id)
      @inn_chemicals = @all_chemicals.select(&:inn?)
      @rest_chemicals = @all_chemicals.reject(&:inn?)
    end

    if params[:country].present? && @search.geographical_area
      @rules_of_origin_schemes = declarable.rules_of_origin(params[:country])
    else
      @roo_all_schemes = RulesOfOrigin::Scheme.all
    end
  end

  def url_options
    @remove_country_url_option ? super.merge(country: nil) : super
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
    Subheading.find("#{params[:id]}-80", query_params, search_tracking_headers)
  end

  def uk_heading
    @uk_heading ||= Rails.cache.fetch(['commodities#uk_heading', cache_key, heading_id, query_params]) do
      TradeTariffFrontend::ServiceChooser.with_source(:uk) do
        HeadingPresenter.new(Heading.find(heading_id, query_params, search_tracking_headers))
      end
    end
  end

  def xi_heading
    @xi_heading ||= Rails.cache.fetch(['commodities#xi_heading', cache_key, heading_id, query_params]) do
      TradeTariffFrontend::ServiceChooser.with_source(:xi) do
        HeadingPresenter.new(Heading.find(heading_id, query_params, search_tracking_headers))
      end
    end
  end

  def uk_commodity
    @uk_commodity ||= Rails.cache.fetch(['commodities#uk_commodity', cache_key, params[:id], query_params]) do
      TradeTariffFrontend::ServiceChooser.with_source(:uk) do
        CommodityPresenter.new(Commodity.find(params[:id], query_params, search_tracking_headers))
      end
    end
  end

  def xi_commodity
    @xi_commodity ||= Rails.cache.fetch(['commodities#xi_commodity', cache_key, params[:id], query_params]) do
      TradeTariffFrontend::ServiceChooser.with_source(:xi) do
        CommodityPresenter.new(Commodity.find(params[:id], query_params, search_tracking_headers))
      end
    end
  end

  def query_params
    query = { filter: {} }
    query[:filter][:meursing_additional_code_id] = meursing_lookup_result.meursing_additional_code_id
    query[:filter][:geographical_area_id] = country if country.present?

    super.merge(query)
  end

  def heading?
    GoodsNomenclature.is_heading_id?(params[:id])
  end

  def heading_id
    params[:id].slice(0, 4)
  end

  def show_validity_periods
    @validity_periods = ValidityPeriod.all(goods_nomenclature_class, params[:id], as_of: query_params[:as_of])
    @commodity_code = params[:id]
    @heading_code = params[:id].first(4)
    @chapter_code = params[:id].first(2)

    @remove_country_url_option = true
    disable_search_form

    render :show_404, status: :not_found
  rescue Faraday::ResourceNotFound
    find_relevant_goods_code_or_fallback
  end

  def goods_nomenclature_class
    heading? ? Heading : Commodity
  end
end
