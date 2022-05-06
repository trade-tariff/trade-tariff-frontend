class SearchReferencePresenter
  attr_reader :search_reference

  def initialize(search_reference)
    @search_reference = search_reference
  end

  def to_s
    search_reference.title.titleize
  end

  def link
    "/#{APP_SLUG}/#{referenced_class.tableize}/#{composite_id}"
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

  def method_missing(*args, &block)
    @search_reference.send(*args, &block)
  end

  def append_product_line_suffix(link)
    link + (referenced_class == 'Subheading' ? "-#{productline_suffix}" : '')
  end
end
