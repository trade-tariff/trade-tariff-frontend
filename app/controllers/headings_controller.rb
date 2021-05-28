class HeadingsController < GoodsNomenclaturesController
  before_action :fetch_heading_from_xi,
                :fetch_heading_from_uk,
                only: %i[show]

  def show
    @commodities = HeadingCommodityPresenter.new(heading.commodities)
    @back_path = request.referer || chapter_path(heading.chapter.short_code)
  end

  private

  def fetch_heading_from_xi
    @xi_heading = TradeTariffFrontend::ServiceChooser.with_source(:xi) do
      HeadingPresenter.new(Heading.find(params[:id], query_params))
    end
  end

  def fetch_heading_from_uk
    @uk_heading = TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      HeadingPresenter.new(Heading.find(params[:id], query_params))
    end
  end

  def heading
    @heading ||= TradeTariffFrontend::ServiceChooser.uk? ? @uk_heading : @xi_heading
  end
end
