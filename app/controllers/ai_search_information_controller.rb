class AiSearchInformationController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner

  def show
    unless TradeTariffFrontend.revised_find_commodity_enabled? && interactive_search_enabled?
      redirect_to find_commodity_path
    end
  end
end
