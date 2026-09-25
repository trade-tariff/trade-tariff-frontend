module FindCommodityPage
  extend ActiveSupport::Concern

  private

  def find_commodity_template
    @ai_search_enabled = interactive_search_enabled_with_analytics?
    @revised_find_commodity = @ai_search_enabled && !TradeTariffFrontend::ServiceChooser.xi?

    if @revised_find_commodity
      disable_switch_service_banner
      submitted_ai = @search.interactive_search || params[:interactive_search] == 'true'
      returning_with_errors = submitted_ai && @search.errors.any?
      # "Start search again" still asks for the AI tab explicitly. A normal visit, including the
      # commodity page link, uses the tab last picked in this browser. Only the exact guided value is
      # honoured: the tab script hides both panels if it is given a mode it does not know.
      requested_guided = params[:search_mode] == 'guided'
      remembered_guided = cookies[:interactive_search] == 'true'
      @search_mode_from_url = requested_guided
      @search_mode = if !@ai_search_enabled
                       'keyword'
                     elsif returning_with_errors || requested_guided
                       'guided'
                     elsif @search.errors.any?
                       'keyword'
                     elsif remembered_guided
                       'guided'
                     else
                       'keyword'
                     end
      'find_commodities/show_revised'
    elsif @ai_search_enabled
      'find_commodities/show_interactive'
    else
      'find_commodities/show'
    end
  end
end
