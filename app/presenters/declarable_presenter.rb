class DeclarablePresenter < TradeTariffFrontend::Presenter
  def to_s
    formatted_description.html_safe
  end

  def self.model_name
    name.chomp('Presenter').constantize.model_name
  end
end
