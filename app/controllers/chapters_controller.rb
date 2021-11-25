class ChaptersController < GoodsNomenclaturesController
  before_action { @no_shared_search = true }
  after_action :set_goods_nomenclature_code

  def show
    @chapter = Chapter.find(params[:id], query_params)
    @headings = @chapter.headings
    @section = @chapter.section
  end

  private

  def set_goods_nomenclature_code
    session[:goods_nomenclature_code] = @chapter.code
  end
end
