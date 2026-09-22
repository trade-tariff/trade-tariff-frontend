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
      # "Start search again" on the AI search end states links here with search_mode=guided, because
      # someone who has just finished an AI search almost certainly wants another one. Only that exact
      # value is honoured: the tab script hides both panels if it is given a mode it does not know.
      requested_guided = params[:search_mode] == 'guided'
      @search_mode = @ai_search_enabled && (returning_with_errors || requested_guided) ? 'guided' : 'keyword'
      'find_commodities/show_revised'
    elsif @ai_search_enabled
      'find_commodities/show_interactive'
    else
      'find_commodities/show'
    end
  end
end
