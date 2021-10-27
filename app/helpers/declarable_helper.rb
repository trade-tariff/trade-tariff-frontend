module DeclarableHelper
  def return_to_declarable_back_link
    link_to('Back', declarable_path, class: 'govuk-back-link')
  end

  def return_to_declarable_link
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
