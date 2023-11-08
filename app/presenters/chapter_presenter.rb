class ChapterPresenter < TradeTariffFrontend::Presenter
  attr_reader :chapter

  def initialize(chapter)
    super

    @chapter = chapter
  end

  def link
    view_context.chapter_path(@chapter)
  end

  private

  # rubocop:disable Style/MissingRespondToMissing
  def method_missing(*args, &block)
    @chapter.send(*args, &block)
  end
  # rubocop:enable Style/MissingRespondToMissing
end
