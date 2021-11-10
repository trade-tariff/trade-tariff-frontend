module DeclarableHelper
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

  def declarable_back_link
    link_to('Back', declarable_path, class: 'govuk-back-link')
  end

  def declarable_link
    link_to("Return to #{current_declarable_code}", declarable_path, class: 'govuk-link')
  end

  def declarable_path
    if current_declarable_code.size == Heading::SHORT_CODE_LENGTH
      heading_path(declarable_path_opts)
    else
      commodity_path(declarable_path_opts)
    end
  end

  def current_declarable_code
    session[:declarable_code]
  end

  private

  def declarable_path_opts
    url_options.merge(
      id: current_declarable_code,
      anchor: anchor,
    )
  end

  def anchor
    referer&.fragment.presence || 'import'
  end

  def referer
    @referer ||= Addressable::URI.parse(request.referer) if request.referer.present?
  end
end
