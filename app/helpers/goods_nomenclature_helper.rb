module GoodsNomenclatureHelper
  def goods_nomenclature_back_link
    link_to('Back', goods_nomenclature_path, class: 'govuk-back-link')
  end

  def goods_nomenclature_path(path_opts = {})
    path_opts = goods_nomenclature_path_opts.merge(path_opts) if current_goods_nomenclature_code.present?

    case current_goods_nomenclature_code&.size
    when nil
      find_commodity_path(path_opts)
    when Chapter::SHORT_CODE_LENGTH
      chapter_path(path_opts)
    when Heading::SHORT_CODE_LENGTH
      heading_path(path_opts)
    else
      commodity_path(path_opts)
    end
  end

  def goods_nomenclature_link
    link_to("Return to #{current_goods_nomenclature_code}", goods_nomenclature_path, class: 'govuk-link')
  end

  def current_goods_nomenclature_code
    session[:goods_nomenclature_code]
  end

  private

  def anchor
    referer&.fragment
  end

  def referer
    @referer ||= Addressable::URI.parse(request.referer) if request.referer.present?
  end

  def goods_nomenclature_path_opts
    url_options.merge(
      id: current_goods_nomenclature_code,
      anchor: anchor,
    )
  end
end
