class SubheadingsController < GoodsNomenclaturesController
  before_action :set_goods_nomenclature_code, only: %i[show]

  def show
    @commodities = HeadingCommodityPresenter.new(subheading.commodities)
    @section = subheading.section
    @chapter = subheading.chapter
    @heading = subheading.heading
  end

  private

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

  def subheading
    @subheading ||= TradeTariffFrontend::ServiceChooser.uk? ? uk_subheading : xi_subheading
  end

  def set_goods_nomenclature_code
    session[:goods_nomenclature_code] = subheading.to_param
  end
end
