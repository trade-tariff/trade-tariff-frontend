module ServiceHelper
  def default_title
    t('title.default', service_name: service_name, service_description: service_description)
  end

  def heading_for(section:, chapter: nil, heading: nil, commodity: nil)
    item = commodity || heading || chapter || section

    item ? item.page_heading : t('h1.service_description')
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

  def import_export_date_title
    t('title.import_export_date', service_name: service_name)
  end

  def trading_partner_title
    t('title.trading_partner', service_name: service_name)
  end

  def trade_tariff_heading
    t("trade_tariff_heading.#{service_choice}")
  end

  # TODO: this method will be refactored/removed in the coming ticket: HOTT-1052
  def switch_service_link
    return link_to(t('service_banner.service_name.xi'), "/xi#{current_path}") if uk_service_choice?

    link_to(t('service_banner.service_name.uk'), current_path)
  end

  def switch_service_button
    copy, link = if uk_service_choice?
                   [t('service_banner.service_name.xi'), "/xi#{current_path}"]
                 else
                   [t('service_banner.service_name.uk'), current_path]
                 end

    tag.span class: 'switch-service-control' do
      safe_join [
        tag.span(class: 'arrow'),
        link_to("Switch to the #{copy}", link, class: 'govuk-link--no-underline'),
      ], "\n"
    end
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

  def service_region
    t("title.region_name.#{service_choice}")
  end

  def replace_service_tags(content)
    content.gsub %r{\[\[SERVICE_[A-Z_]+\]\]} do |match|
      case match
      when '[[SERVICE_NAME]]'
        service_name
      when '[[SERVICE_PATH]]'
        TradeTariffFrontend::ServiceChooser.xi? ? '/xi' : ''
      when '[[SERVICE_REGION]]'
        service_region
      else
        match
      end
    end
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
