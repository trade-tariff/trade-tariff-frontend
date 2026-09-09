module FindCommodityPage
  extend ActiveSupport::Concern

  private

  def find_commodity_template
    @ai_search_enabled = interactive_search_enabled_with_analytics?
    @revised_find_commodity = @ai_search_enabled && !TradeTariffFrontend::ServiceChooser.xi?

    if @revised_find_commodity
      disable_switch_service_banner
      submitted_ai = @search.interactive_search || params[:interactive_search] == 'true'
      @search_mode = @ai_search_enabled && submitted_ai && @search.errors.any? ? 'guided' : 'keyword'
      'find_commodities/show_revised'
    elsif @ai_search_enabled
      'find_commodities/show_interactive'
    else
      'find_commodities/show'
    end
  end
end
