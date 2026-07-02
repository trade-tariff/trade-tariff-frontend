class ChapterPresenter < TradeTariffFrontend::Presenter
  attr_reader :chapter

  def initialize(chapter)
    super

    @chapter = chapter
  end

  def link
    view_context.chapter_path(@chapter)
  end
end
