class SubheadingsController < GoodsNomenclaturesController
  rescue_from Faraday::ResourceNotFound, with: :show_validity_periods

  def show
    @commodities = HeadingCommodityPresenter.new(subheading.commodities)
    @subheading_commodities = @subheading.descendants
    @section = subheading.section
    @chapter = subheading.chapter
    @heading = subheading.heading
  end

  def url_options
    @remove_country_url_option ? super.merge(country: nil) : super
  end

  private

  def subheading
    @subheading ||= TradeTariffFrontend::ServiceChooser.uk? ? uk_subheading : xi_subheading
  end

  def uk_subheading
    @uk_subheading ||= TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      Subheading.find(params[:id], query_params)
    end
  end

  def xi_subheading
    @xi_subheading ||= TradeTariffFrontend::ServiceChooser.with_source(:xi) do
      Subheading.find(params[:id], query_params)
    end
  end

  def show_validity_periods
    @validity_periods = ValidityPeriod.all(Subheading, params[:id], query_params)
    @subheading_code = params[:id].first(10)
    @commodity_code = @subheading_code
    @chapter_code = params[:id].first(2)

    @remove_country_url_option = true
    disable_search_form

    render :show_404, status: :not_found
  rescue Faraday::ResourceNotFound
    find_relevant_goods_code_or_fallback
  end
end
