class SearchReferencePresenter
  attr_reader :search_reference

  def initialize(search_reference)
    @search_reference = search_reference
  end

  def to_s
    search_reference.title.titleize
  end

  def link
    reference_link = "/#{APP_SLUG}/#{referenced_class.tableize}/#{referenced_id}"

    append_product_line_suffix(reference_link)
  end

  private

  def method_missing(*args, &block)
    @search_reference.send(*args, &block)
  end

  def append_product_line_suffix(link)
    link + (referenced_class == 'Subheading' ? "-#{productline_suffix}" : '')
  end
end
