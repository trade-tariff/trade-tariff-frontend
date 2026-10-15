module FindCommodityPage
  extend ActiveSupport::Concern

private

  def find_commodity_template
    @ai_search_enabled = interactive_search_enabled_with_analytics? && !TradeTariffFrontend::ServiceChooser.xi?
    @revised_find_commodity = true
    disable_switch_service_banner
    submitted_ai = @search.interactive_search || params[:interactive_search] == 'true'
    returning_with_errors = submitted_ai && @search.errors.any?
    # A normal visit remembers the last search tab. Only the exact guided value
    # can override it, so an unknown mode cannot hide both panels.
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
    'find_commodities/show'
  end
end
