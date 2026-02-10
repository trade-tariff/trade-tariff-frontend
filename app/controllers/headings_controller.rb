class HeadingsController < GoodsNomenclaturesController
  helper_method :uk_heading, :xi_heading

  def show
    fetch_heading

    redirect_to commodity_path(id: heading.id) if heading.declarable?

    @commodities = HeadingCommodityPresenter.new(heading.commodities)
    @meursing_additional_code = session[:meursing_lookup].try(:[], 'result')
    @section = heading.section
    @chapter = heading.chapter

    if params[:country].present? && @search.geographical_area
      @rules_of_origin_schemes = heading.rules_of_origin(params[:country])
    end
  rescue Faraday::ResourceNotFound
    @validity_periods = ValidityPeriod.all(Heading, params[:id])
    @heading_code = params[:id]
    @chapter_code = params[:id].first(2)

    @remove_country_url_option = true
    disable_search_form

    render :show_404, status: :not_found
  end

  def url_options
    @remove_country_url_option ? super.merge(country: nil) : super
  end

  private

  def fetch_heading_from_xi
    @xi_heading = TradeTariffFrontend::ServiceChooser.with_source(:xi) do
      HeadingPresenter.new(Heading.find(params[:id], query_params, search_tracking_headers))
    end
  end

  def fetch_heading_from_uk
    @uk_heading = TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      HeadingPresenter.new(Heading.find(params[:id], query_params, search_tracking_headers))
    end
  end

  def fetch_heading
    @headings ||= {}

    @meursing_additional_code = session[MeursingLookup::Result::CURRENT_MEURSING_ADDITIONAL_CODE_KEY]

    if TradeTariffFrontend::ServiceChooser.uk?
      @headings[:uk] = HeadingPresenter.new(Heading.find(params[:id], query_params, search_tracking_headers))
      @headings[:xi] = nil
    else
      @headings[:xi] = HeadingPresenter.new(Heading.find(params[:id], query_params, search_tracking_headers))
      @headings[:uk] = TradeTariffFrontend::ServiceChooser.with_source(:uk) do
        HeadingPresenter.new(Heading.find(params[:id], query_params, search_tracking_headers))
      end
    end
  end

  def heading
    @heading ||= TradeTariffFrontend::ServiceChooser.uk? ? uk_heading : xi_heading
  end

  def xi_heading
    @headings[:xi]
  end

  def uk_heading
    @headings[:uk]
  end

  def query_params
    super.merge(filter: { meursing_additional_code_id: meursing_lookup_result.meursing_additional_code_id })
  end
end
