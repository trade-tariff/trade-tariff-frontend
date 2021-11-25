class ChaptersController < GoodsNomenclaturesController
  before_action { @no_shared_search = true }

  def show
    @chapter = Chapter.find(params[:id], query_params)
    @headings = @chapter.headings
    @section = @chapter.section
  end
end
