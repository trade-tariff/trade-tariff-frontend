class DeclarablePresenter < TradeTariffFrontend::Presenter
  MEURSING_TOOL_LINK = 'http://ec.europa.eu/taxation_customs/dds2/taric/measures.jsp?Lang=en&SimDate=%{date}&Taric=%{commodity_code}&LangDescr=en'.freeze

  def to_s
    formatted_description.html_safe
  end

  def meursing_tool_link_for(date)
    sprintf(MEURSING_TOOL_LINK, date: date, commodity_code: code)
  end

  def self.model_name
    name.chomp('Presenter').constantize.model_name
  end
end
