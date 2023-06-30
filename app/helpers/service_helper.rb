module ServiceHelper
  def default_title
    t('title.default', service_name:, service_description:)
  end

  def goods_nomenclature_title(goods_nomenclature)
    t(
      'title.goods_nomenclature',
      goods_description: goods_nomenclature.description_plain,
      service_name:,
    )
  end

  def commodity_title(commodity)
    t(
      "title.commodity.#{service_choice}",
      commodity_description: commodity.to_s,
      commodity_code: commodity.code,
      service_name:,
    )
  end

  def import_export_date_title
    t('title.import_export_date', service_name:)
  end

  def trading_partner_title
    t('title.trading_partner', service_name:)
  end

  def trade_tariff_heading
    t("trade_tariff_heading.#{service_choice}")
  end

  # TODO: this method will be refactored/removed in the coming ticket: HOTT-1052
  def switch_service_link
    return link_to(t('service_banner.service_name.xi'), "/xi#{current_path}") if uk_service_choice?

    link_to(t('service_banner.service_name.uk'), current_path, class: 'govuk-!-display-none-print')
  end

  def switch_service_button
    copy, link = if uk_service_choice?
                   [t('service_banner.service_name.xi'), "/xi#{current_path}"]
                 else
                   [t('service_banner.service_name.uk'), current_path]
                 end

    tag.span class: %w[switch-service-control govuk-!-display-none-print] do
      safe_join [
        tag.span(class: 'arrow'),
        link_to("Switch to the #{copy}", link, class: 'govuk-link--no-underline'),
      ], "\n"
    end
  end

  def search_label_text
    t('search.label', service_name:)
  end

  def measures_heading(anchor:)
    t("measures_heading.#{service_choice}.#{anchor}")
  end

  def country_picker_text
    t("country_picker.#{service_choice}_html")
  end

  def service_choice
    TradeTariffFrontend::ServiceChooser.service_choice ||
      TradeTariffFrontend::ServiceChooser.service_default
  end

  def import_destination
    t("import_destination.#{service_choice}")
  end

  def uk_service_choice?
    service_choice == 'uk'
  end

  def switch_banner_bottom_copy
    t("service_banner.bottom.#{service_choice}")
  end

  def service_region
    t("title.region_name.#{service_choice}")
  end

  def replace_service_tags(content)
    content.gsub %r{\[\[[A-Z]+_[A-Z_]+\]\]} do |match|
      case match
      when '[[SERVICE_NAME]]'
        service_name
      when '[[SERVICE_PATH]]'
        service_path_prefix
      when '[[SERVICE_REGION]]'
        service_region
      when '[[LOCALE_PATH]]'
        locale_path_prefix
      when '[[PREFIX_PATH]]'
        "#{service_path_prefix}#{locale_path_prefix}"
      else
        match
      end
    end
  end

  def insert_service_links(html)
    return html if uk_service_choice? || html.blank?

    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    doc.xpath(".//a[not(starts-with(@href, 'http')) and not(starts-with(@href, '/xi'))]").each do |link|
      link['href'] = File.join('/xi', link['href'])
    end

    doc.to_html.html_safe
  end

private

  def service_name
    t("title.service_name.#{service_choice}")
  end

  def service_description
    t('title.service_description')
  end

  def current_path
    path, query_string = request.filtered_path.split('?', 2)

    components = path.to_s.split('/')
                          .reject(&:blank?)
                          .reject { |c| c == service_choice }

    if query_string.blank?
      "/#{components.join('/')}"
    else
      "/#{components.join('/')}?#{query_string}"
    end
  end

  def service_path_prefix
    TradeTariffFrontend::ServiceChooser.xi? ? '/xi' : ''
  end

  def locale_path_prefix
    I18n.locale == I18n.default_locale ? '' : "/#{I18n.locale}"
  end
end
