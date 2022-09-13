class SubheadingsController < GoodsNomenclaturesController
  before_action :set_goods_nomenclature_code, only: %i[show]

  def show
    @commodities = HeadingCommodityPresenter.new(subheading.commodities)
    @subheading_commodities = Array.wrap(@subheading.find_self_in_commodities_list)
    @section = subheading.section
    @chapter = subheading.chapter
    @heading = subheading.heading
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

  def set_goods_nomenclature_code
    session[:goods_nomenclature_code] = subheading.to_param
  end

  rescue_from Faraday::ResourceNotFound do
    commodity_code = params[:id].split('-').first

    redirect_to commodity_url(id: commodity_code)
  end
end
