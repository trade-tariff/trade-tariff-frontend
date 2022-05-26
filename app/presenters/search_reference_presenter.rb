class SearchReferencePresenter < SimpleDelegator
  def to_s
    title.titleize
  end

  def link
    "/#{referenced_class.tableize}/#{composite_id}"
  end

  def composite_id
    case referenced_class
    when 'Subheading'
      "#{referenced_id}-#{productline_suffix}"
    else
      referenced_id
    end
  end

  private

  def append_product_line_suffix(link)
    link + (referenced_class == 'Subheading' ? "-#{productline_suffix}" : '')
  end
end
