module ServiceHelper
  def default_title
    t('title.default', service_name: service_name, service_description: service_description)
  end

  def default_heading(section:)
    section ? section_heading(section) : t('h1.service_description')
  end

  def section_heading(section)
    "Section #{section.numeral}: #{section.title}"
  end

  def goods_nomenclature_title(goods_nomenclature)
    t(
      'title.goods_nomenclature',
      goods_description: goods_nomenclature.to_s,
      service_name: service_name,
    )
  end

  def commodity_title(commodity)
    t(
      "title.commodity.#{service_choice}",
      commodity_description: commodity.to_s,
      commodity_code: commodity.code,
      service_name: service_name,
    )
  end

  def trade_tariff_heading
    t("trade_tariff_heading.#{service_choice}")
  end

  # TODO: this method will be refactored/removed in the coming ticket: HOTT-1052
  def switch_service_link
    return link_to(t('service_banner.service_name.xi'), "/xi#{current_path}") if uk_service_choice?

    link_to(t('service_banner.service_name.uk'), current_path)
  end

  def switch_service_bottom_link
    copy, link = if uk_service_choice?
                   [t('service_banner.service_name.xi'), "/xi#{current_path}"]
                 else
                   [t('service_banner.service_name.uk'), current_path]
                 end

    link_to("Switch to the #{copy}", link, class: 'govuk-link--no-underline')
  end

  def search_label_text
    t('search.label', service_name: service_name)
  end

  def measures_heading(tab: 'import')
    t("measures_heading.#{service_choice}.#{tab}").html_safe
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

  def switch_banner_copy
    copy = request.filtered_path == sections_path ? "service_banner.big.#{service_choice}" : 'service_banner.small'

    t(copy, link: switch_service_link).html_safe
  end

  def switch_banner_bottom_copy
    t("service_banner.bottom.#{service_choice}")
  end

private

  def service_name
    t("title.service_name.#{service_choice}")
  end

  def service_description
    t('title.service_description')
  end

  def current_path
    request.filtered_path.sub("/#{service_choice}", '')
  end
end
