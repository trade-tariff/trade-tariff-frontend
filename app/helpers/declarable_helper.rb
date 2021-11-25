module DeclarableHelper
  def classification_description(commodity)
    tree_items = if commodity.heading?
                   [commodity]
                 else
                   [commodity.heading,
                    commodity.ancestors,
                    commodity]
                 end

    descriptions = tree_items
      .flatten
      .map(&:description)

    boldify_last(descriptions)
      .join(' &mdash; ')
      .html_safe
  end

  def declarable_stw_link(declarable, search)
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
      "Check how to import #{declarable_type} #{declarable.code} from #{geographical_area&.description}.",
      stw_link,
      target: '_blank',
      class: 'govuk-link',
      rel: 'noopener',
    )
  end

  def goods_nomenclature_back_link
    link_to('Back', goods_nomenclature_path, class: 'govuk-back-link')
  end

  def declarable_link
    link_to("Return to #{current_goods_nomenclature_code}", goods_nomenclature_path, class: 'govuk-link')
  end

  def goods_nomenclature_path(path_opts = {})
    path_opts = goods_nomenclature_path_opts.merge(path_opts) if current_goods_nomenclature_code.present?

    case current_goods_nomenclature_code&.size
    when nil
      sections_path(path_opts)
    when Chapter::SHORT_CODE_LENGTH
      chapter_path(path_opts)
    when Heading::SHORT_CODE_LENGTH
      heading_path(path_opts)
    else
      commodity_path(path_opts)
    end
  end

  def current_goods_nomenclature_code
    session[:goods_nomenclature_code]
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

  def goods_nomenclature_path_opts
    url_options.merge(
      id: current_goods_nomenclature_code,
      anchor: anchor,
    )
  end

  def anchor
    referer&.fragment
  end

  def referer
    @referer ||= Addressable::URI.parse(request.referer) if request.referer.present?
  end

  def boldify_last(items)
    starting_items = items[..-2]
    starting_items << "<strong>#{items.last}</strong>"
  end
end
