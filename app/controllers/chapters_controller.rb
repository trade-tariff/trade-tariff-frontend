class ChaptersController < GoodsNomenclaturesController
  def show
    @chapter = Chapter.find(params[:id], query_params, backend_request_headers)
    @headings = @chapter.headings
    @section = @chapter.section
  end
end
