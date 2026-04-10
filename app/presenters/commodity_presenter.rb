class CommodityPresenter < DeclarablePresenter
  def link
    view_context.commodity_path(declarable)
  end

  def leaf_position
    ' last-child' if last_child?
  end

  def commodity_level(initial_indent = nil)
    initial_indent ||= 1
    normalized_indent = number_indents - initial_indent + 1
    "level-#{normalized_indent}"
  end
end
