class SearchReferencePresenter < SimpleDelegator
  def to_s
    title.capitalize
  end

  def link
    "/#{referenced_class.tableize}/#{referenced_id}"
  end
end
