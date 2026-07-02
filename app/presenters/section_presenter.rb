class SectionPresenter < TradeTariffFrontend::Presenter
  attr_reader :section

  def initialize(section)
    super

    @section = section
  end

  def link
    view_context.section_path(@section)
  end

end
