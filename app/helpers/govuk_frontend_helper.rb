module GovukFrontendHelper
  def contents_list_item(text, href, classes = [])
    list_item_classes = %w[
      gem-c-contents-list__list-item
      gem-c-contents-list__list-item--dashed
    ]

    link_classes = Array.wrap(classes)
    link_classes.unshift('gem-c-contents-list__link')

    tag.li class: list_item_classes do
      link_to text, href, class: link_classes
    end
  end
end
