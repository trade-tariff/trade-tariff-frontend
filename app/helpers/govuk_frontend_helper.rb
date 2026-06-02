module GovukFrontendHelper
  module_function

  def contents_list_item(text, target, classes = [], &_block)
    list_item_classes = %w[
      gem-c-contents-list__list-item
      gem-c-contents-list__list-item--dashed
    ]

    target = yield(target) if block_given?

    link_classes = Array.wrap(classes)
    link_classes.unshift('gem-c-contents-list__link')

    tag.li class: list_item_classes do
      link_to text, target, class: link_classes
    end
  end

  def back_to_top_link
    link_to t('navigation.back_to_top'), '#content', class: 'govuk-!-display-none-print'
  end

  def app_filter(title:,
                 action:,
                 result_count: nil,
                 clear_path: nil,
                 selected_filters: [],
                 selected_filters_heading: I18n.t('components.filter.selected_filters'),
                 submit_text: I18n.t('components.filter.apply'),
                 clear_text: I18n.t('components.filter.clear'),
                 classes: nil,
                 method: :get,
                 &block)
    render(
      'shared/components/filter',
      title:,
      action:,
      method:,
      result_count:,
      clear_path:,
      selected_filters:,
      selected_filters_heading:,
      submit_text:,
      clear_text:,
      classes: (['govuk-!-margin-bottom-4', 'app-c-filter'] + Array(classes)).join(' '),
      form_content: block_given? ? capture(&block) : nil,
    )
  end

  def contents_list(list_items,
                    title: I18n.t('generic.contents'),
                    classes: [],
                    item_classes: [],
                    **options,
                    &block)
    items_html = list_items.map do |link_text, target|
      contents_list_item(link_text, target, item_classes, &block)
    end

    nav_options = options.reverse_merge(
      class: %w[gem-c-contents-list] + Array.wrap(classes),
      role: 'navigation',
    )

    list_html = tag.ol(class: 'gem-c-contents-list__list') do
      safe_join items_html, "\n"
    end

    heading = title ? tag.h2(title, class: 'gem-c-contents-list__title') : ''

    tag.nav(**nav_options) do
      heading + list_html
    end
  end

  # Count UTF-16 code units (how JS .length / maxlength measure length)
  def utf16_code_units_length(str)
    normalize_newlines(str).encode('UTF-16LE').bytesize / 2
  end

  # remove extra characters from newlines so it matches frontend character count
  def normalize_newlines(str)
    str.to_s.gsub("\r\n", "\n").tr("\r", "\n")
  end
end
