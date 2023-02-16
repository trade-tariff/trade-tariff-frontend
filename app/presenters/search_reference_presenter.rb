class SearchReferencePresenter < SimpleDelegator
  def to_s
    title.titleize
  end

  def link
    "/#{referenced_class.tableize}/#{referenced_id}"
  end
end
