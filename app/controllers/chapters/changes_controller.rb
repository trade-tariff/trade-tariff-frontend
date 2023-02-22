module Chapters
  class ChangesController < ::ChangesController
    private

    def changeable
      @changeable ||= Chapter.find(params[:chapter_id], query_params)
    end

    def change_path(*)
      chapter_path(changeable)
    end
  end
end
