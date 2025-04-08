module GoodsNomenclatureHelper
  def goods_nomenclature_back_link
    link_to('Back', goods_nomenclature_path, class: 'govuk-back-link')
  end

  def goods_nomenclature_path(path_opts = {})
    path_opts = goods_nomenclature_path_opts.merge(path_opts) if current_goods_nomenclature_code.present?

    case current_goods_nomenclature_code&.size
    when nil, 0
      home_path(path_opts)
    when Chapter::SHORT_CODE_LENGTH
      chapter_path(path_opts)
    when Heading::SHORT_CODE_LENGTH
      heading_path(path_opts)
    when Subheading::FULL_CODE_LENGTH
      subheading_path(path_opts)
    else
      commodity_path(path_opts)
    end
  end

  def goods_nomenclature_link
    link_to("Return to #{current_goods_nomenclature_code}", goods_nomenclature_path, class: 'govuk-link')
  end

  def goods_nomenclature_back_to_commodity_link
    link_to("Back to commodity #{current_goods_nomenclature_code}", goods_nomenclature_path, class: 'govuk-back-link')
  end

  def current_goods_nomenclature_code
    @goods_nomenclature_code
  end

  def referer_goods_nomenclature_code(referer_link)
    referer_link.match(%r{/commodities/(\d+)})[1] if referer_link.present? && referer_link.match(%r{/commodities/(\d+)}).present?
  end

  private

  def anchor
    referer&.fragment
  end

  def referer
    @referer ||= URI(request.referer) if request.referer.present?
  end

  def goods_nomenclature_path_opts
    url_options.merge(
      id: current_goods_nomenclature_code,
      anchor:,
    )
  end
end
