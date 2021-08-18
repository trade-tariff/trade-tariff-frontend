class HeadingsController < GoodsNomenclaturesController
  before_action :fetch_heading,
                only: %i[show]

  helper_method :uk_heading, :xi_heading

  def show
    @commodities = HeadingCommodityPresenter.new(heading.commodities)
    @back_path = request.referer || chapter_path(heading.chapter.short_code)

    if params[:country].present?
      @rules_of_origin = heading.rules(params[:country])
    end
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

  def fetch_heading
    @headings ||= {}

    if TradeTariffFrontend::ServiceChooser.uk?
      @headings[:uk] = HeadingPresenter.new(Heading.find(params[:id], query_params))
      @headings[:xi] = nil
    else
      @headings[:xi] = HeadingPresenter.new(Heading.find(params[:id], query_params))
      @headings[:uk] = TradeTariffFrontend::ServiceChooser.with_source(:uk) do
        HeadingPresenter.new(Heading.find(params[:id], query_params))
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
end
