module DeclarableHelper
  def declarable_stw_html(declarable, search, anchor = 'import')
    code = declarable.code

    return I18n.t('stw_link.no_country_html', code:) if search.country.blank?

    trading_partner_description = search.country_description

    if declarable.one_or_more_prohibitive_measures?
      I18n.t('stw_link.prohibitive_html', code:, trading_partner_description:)
    elsif declarable.one_or_more_conditionally_prohibitive_measures?
      I18n.t('stw_link.conditionally_prohibitive_html', code:, trading_partner_description:)
    else
      declarable_stw_link(declarable, search, anchor)
    end
  end

  def declarable_stw_link(declarable, search, anchor = 'import')
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
      "Check how to #{anchor} #{declarable_type} #{declarable.code} from #{search.geographical_area&.description} (opens in a new tab).",
      stw_link,
      target: '_blank',
      class: 'govuk-link',
      rel: 'noopener',
    )
  end

  def trading_partner_country_description(geographical_area_id)
    if geographical_area_id.present?
      GeographicalArea.find(geographical_area_id).description
    else
      'All countries'
    end
  end

  def declarable_path_json(declarable)
    if declarable.heading?
      heading_path(declarable, format: :json)
    else
      commodity_path(declarable, format: :json)
    end
  end

  # Supplementary units coming from the UK declarable excise measures
  # need to be displayed when there are no units on the XI declarable.
  def supplementary_unit_for(declarable, uk_declarable)
    supplementary_unit = if declarable.has_supplementary_unit? || !uk_declarable
                           declarable.supplementary_unit
                         else
                           uk_declarable.supplementary_unit
                         end

    sanitize supplementary_unit
  end
end
