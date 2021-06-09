class GoodsNomenclaturesController < ApplicationController
  rescue_from ApiEntity::NotFound, with: :find_relevant_goods_code_or_fallback

  private

  def goods_code_id
    params.fetch(:id, '')
  end

  def find_relevant_goods_code_or_fallback
    # Restore the request's original service, since this rescue branch will
    # always be triggered from `fetch_heading_from_xi` in CommoditiesController
    # and from `fetch_heading_from_xi` in HeadingsController, regardless of
    # whether the original call was from UK or XI
    service_match = RoutingFilter::ServicePathPrefixHandler::SERVICE_CHOICE_PREFIXES_REGEX.match(request.path)
    original_service_choice = service_match.present? ? service_match[1] : nil
    TradeTariffFrontend::ServiceChooser.service_choice = original_service_choice

    @search = Search.new(q: goods_code_id, as_of: @tariff_last_updated)
    results = @search.perform

    if results.exact_match?
      redirect_to url_for(results.to_param.merge(url_options))
    else
      redirect_to sections_url
    end
  end
end
