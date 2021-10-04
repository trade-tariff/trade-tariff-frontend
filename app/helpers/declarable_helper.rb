module DeclarableHelper
  def return_to_declarable_link
    link_to("Return to #{current_declarable_code}", declarable_path, class: 'govuk-link', anchor: 'import')
  end

  def declarable_path
    if current_declarable_code.size == Heading::SHORT_CODE_LENGTH
      heading_path(id: current_declarable_code, anchor: 'import')
    else
      commodity_path(id: current_declarable_code, anchor: 'import')
    end
  end

  def current_declarable_code
    session[:declarable_code]
  end
end
