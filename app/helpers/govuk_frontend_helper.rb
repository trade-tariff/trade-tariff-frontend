module GovukFrontendHelper
  module_function

  RELATED_NAV_LINK_CLASSES = %w[
    govuk-link
    gem-c-related-navigation__section-link
    gem-c-related-navigation__section-link--sidebar
    gem-c-related-navigation__section-link--other
  ].freeze

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

  def contextual_sidebar(classes: nil, &block)
    tag.div(class: class_names('gem-c-contextual-sidebar', 'govuk-!-margin-bottom-0', classes)) do
      capture(&block)
    end
  end

  def related_navigation(title: nil,
                         links: nil,
                         wrapper: false,
                         classes: nil,
                         **section_options,
                         &block)
    navigation = tag.div(class: class_names('gem-c-related-navigation', classes)) do
      if block_given?
        capture(&block)
      else
        related_navigation_section(title:, links:, **section_options)
      end
    end

    wrapper ? contextual_sidebar { navigation } : navigation
  end

  def related_navigation_section(title:,
                                 links: nil,
                                 heading_level: 2,
                                 heading_id: nil,
                                 heading_attributes: {},
                                 nav_attributes: {},
                                 list_attributes: {},
                                 &block)
    nav_options = nav_attributes.deep_dup
    nav_options[:role] = 'navigation' unless nav_options.key?(:role)
    nav_options[:class] = class_names('gem-c-related-navigation__nav-section', nav_options[:class])
    nav_options[:aria] ||= {}

    labelledby = heading_id.presence || nav_options[:aria][:labelledby].presence
    nav_options[:aria][:labelledby] ||= labelledby if labelledby.present?

    heading_options = heading_attributes.deep_dup
    heading_options[:id] = labelledby if labelledby.present?
    heading_options[:class] = class_names('gem-c-related-navigation__main-heading', heading_options[:class])

    nav_content = if block_given?
                    capture(&block)
                  else
                    related_navigation_link_list(links || [], list_attributes:)
                  end

    safe_join [
      tag.public_send(:"h#{heading_level}", title, **heading_options),
      tag.nav(**nav_options) { nav_content },
    ], "\n"
  end

  def related_navigation_link_list(links, list_attributes: {})
    list_options = list_attributes.deep_dup
    list_options[:class] = class_names('gem-c-related-navigation__link-list', list_options[:class])

    tag.ul(**list_options) do
      safe_join links.map { |link| related_navigation_link_item(link) }, "\n"
    end
  end

  def related_navigation_link_item(link)
    text, href, options = related_navigation_link_parts(link)
    options[:class] = class_names(RELATED_NAV_LINK_CLASSES, options[:class])

    tag.li(class: 'gem-c-related-navigation__link') do
      link_to(text, href, options)
    end
  end

  def related_navigation_link_parts(link)
    case link
    when Hash
      [
        link.fetch(:text),
        link.fetch(:href),
        link.fetch(:options, {}).deep_dup,
      ]
    else
      text, href, options = Array(link)
      [text, href, (options || {}).deep_dup]
    end
  end

  def card_list(cards: nil,
                heading: nil,
                heading_level: 2,
                wrapper: true,
                classes: nil,
                list_classes: 'gem-c-cards__list--one-column',
                &block)
    content = safe_join [
      (tag.public_send(:"h#{heading_level}", heading, class: 'gem-c-cards__heading govuk-heading-m gem-c-cards__heading--underline') if heading.present?),
      tag.ul(class: class_names('gem-c-cards__list', list_classes)) do
        if block_given?
          capture(&block)
        else
          safe_join Array(cards).map { |card_options| card(**card_options) }, "\n"
        end
      end,
    ].compact, "\n"

    wrapper ? tag.div(content, class: class_names('gem-c-cards', classes)) : content
  end

  def card(title:, href:, description:, status: nil, status_colour: 'magenta', link_options: {}, heading_level: 2)
    tag.li(class: 'gem-c-cards__list-item') do
      tag.div(class: 'gem-c-cards__list-item-wrapper') do
        safe_join [
          (tag.strong(status, class: class_names('govuk-tag', "govuk-tag--#{status_colour}", 'gem-c-cards__status')) if status.present?),
          tag.public_send(:"h#{heading_level}", class: 'gem-c-cards__sub-heading govuk-heading-s') do
            link_to title, href, { class: 'govuk-link gem-c-cards__link' }.merge(link_options)
          end,
          tag.p(description, class: 'govuk-body gem-c-cards__description'),
        ].compact, "\n"
      end
    end
  end

  def app_card(classes: nil, **options, &block)
    options[:class] = class_names('app-card', options[:class], classes)
    tag.div(**options) { capture(&block) }
  end

  def feature_panel(last: false, shaded: false, no_bottom_border: false, classes: nil, **options, &block)
    options[:class] = class_names(
      'feature-panel',
      ('last-feature-panel' if last),
      ('feature-panel--shaded' if shaded),
      ('no-bottom-border' if no_bottom_border),
      options[:class],
      classes,
    )

    tag.div(**options) { capture(&block) }
  end

  def shaded_inset_panel(classes: nil, **options, &block)
    govuk_inset_text(
      classes: class_names('govuk-inset-text--s', 'feature-panel--shaded', options.delete(:class), classes),
      html_attributes: options,
      &block
    )
  end

  def tariff_information_inset(classes: nil, **options, &block)
    govuk_inset_text(
      classes: class_names('tariff-inset-information', options.delete(:class), classes),
      html_attributes: options,
      &block
    )
  end

  def tariff_meursing_inset(classes: nil, **options, &block)
    govuk_inset_text(
      classes: class_names('govuk-inset-text--s', 'no-inset', 'tariff-inset-meursing', options.delete(:class), classes),
      html_attributes: options,
      &block
    )
  end

  def measure_inset(classes: nil, **options, &block)
    options[:class] = class_names('measure-inset', options[:class], classes)
    tag.div(**options) { capture(&block) }
  end

  def downloadable_document(origin_reference_document:, article_match:)
    render(
      'shared/components/downloadable_document',
      origin_reference_document:,
      article_match:,
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
