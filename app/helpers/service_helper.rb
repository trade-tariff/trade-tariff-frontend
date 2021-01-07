module ServiceHelper
  def default_title
    t('title.default', service_name: service_name, service_description: service_description)
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

  def switch_service_link
    return link_to(t('service_banner.service_name.xi'), "/xi#{current_path}") if uk_service_choice?

    link_to(t('service_banner.service_name.uk'), current_path)
  end

  def service_switch_banner(optional_classes: 'govuk-!-margin-bottom-7')
    if TradeTariffFrontend::ServiceChooser.enabled?
      tag.div(class: "tariff-breadcrumbs js-tariff-breadcrumbs clt govuk-!-font-size-15 #{optional_classes}") do
        tag.nav do
          tag.p do
            banner_copy
          end
        end
      end
    end
  end

private

  def uk_service_choice?
    service_choice == 'uk'
  end

  def service_name
    t("title.service_name.#{service_choice}")
  end

  def service_description
    t('title.service_description')
  end

  def service_choice
    TradeTariffFrontend::ServiceChooser.service_choice ||
      TradeTariffFrontend::ServiceChooser.service_default
  end

  def banner_copy
    return t("service_banner.big.#{service_choice}", link: switch_service_link).html_safe if request.filtered_path == sections_path

    t('service_banner.small', link: switch_service_link).html_safe
  end

  def current_path
    request.filtered_path.sub("/#{service_choice}", '')
  end
end
