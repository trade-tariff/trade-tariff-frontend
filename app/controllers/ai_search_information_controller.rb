class AiSearchInformationController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner

  def show
    redirect_to find_commodity_path unless interactive_search_enabled?
  end
end
