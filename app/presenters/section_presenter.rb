class SectionPresenter < TradeTariffFrontend::Presenter
  attr_reader :section

  def initialize(section)
    super

    @section = section
  end

  def link
    view_context.section_path(@section)
  end

  private

  # rubocop:disable Style/MissingRespondToMissing
  def method_missing(*args, &block)
    @section.send(*args, &block)
  end
  # rubocop:enable Style/MissingRespondToMissing
end
