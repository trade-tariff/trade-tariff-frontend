class SectionsController < GoodsNomenclaturesController
  prepend_before_action :redirect_to_find_commodity, only: :index

  def index
    @tariff_updates = TariffUpdate.all
    @sections = Section.all
    @section_css = 'sections-context'
    @latest_news = NewsItem.latest_for_home_page
  end

  def show
    @section = Section.find(params[:id], query_params)
    @chapters = @section.chapters
  end

  private

  def find_relevant_goods_code_or_fallback
    redirect_to sections_url
  end

  def redirect_to_find_commodity
    redirect_to find_commodity_path if TradeTariffFrontend.updated_navigation?
  end
end
