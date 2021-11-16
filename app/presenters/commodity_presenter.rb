class CommodityPresenter < DeclarablePresenter
  def link
    view_context.commodity_path(declarable)
  end
end
