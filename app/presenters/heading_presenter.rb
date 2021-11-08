class HeadingPresenter < DeclarablePresenter
  def link
    view_context.heading_path(declarable)
  end
end
