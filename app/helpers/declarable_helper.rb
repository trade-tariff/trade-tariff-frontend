module DeclarableHelper
  def classification_description(declarable)
    tree_items = if declarable.heading?
                   [declarable]
                 else # it is a commodity
                   [declarable.heading,
                    declarable.ancestors,
                    declarable]
                 end

    descriptions = tree_items
      .flatten
      .map(&:description)

    boldify_last(descriptions)
      .join(' &mdash; ')
      .html_safe
  end

  def declarable_stw_link(declarable, search, anchor = 'import')
    geographical_area = GeographicalArea.find(search.country)
    declarable_type = declarable.heading? ? 'heading' : 'commodity'
    today = Time.zone.today

    stw_options = {
      commodity: declarable.code,
      originCountry: search.country,
      goodsIntent: 'bringGoodsToSell',
      userTypeTrader: 'true',
      tradeType: 'import',
      destinationCountry: 'GB',
      importDeclarations: 'yes',
      importOrigin: nil,
      importDateDay: search.day.presence || today.day,
      importDateMonth: search.month.presence || today.month,
      importDateYear: search.year.presence || today.year,
    }

    stw_link = "#{TradeTariffFrontend.single_trade_window_url}?#{CGI.unescape(stw_options.to_query)}"
    link_to(
      "check how to #{anchor} #{declarable_type} #{declarable.code} from #{geographical_area&.description}.",
      stw_link,
      target: '_blank',
      class: 'govuk-link',
      rel: 'noopener',
    )
  end

  # Supplementary unit measures treat no country specified in the search as the entire world
  def supplementary_geographical_area_id(search)
    search.country || GeographicalArea::ERGA_OMNES
  end

  def trading_partner_country_description(geographical_area_id)
    if geographical_area_id.present?
      GeographicalArea.find(geographical_area_id).description
    else
      'All countries'
    end
  end

  def declarable_url_json(declarable)
    if declarable.heading?
      heading_url(declarable, format: :json)
    else
      commodity_url(declarable, format: :json)
    end
  end

  private

  def boldify_last(items)
    starting_items = items[..-2]
    starting_items << "<strong>#{items.last}</strong>"
  end
end
