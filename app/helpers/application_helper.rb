module ApplicationHelper
  def govspeak(text)
    text = text['content'] || text[:content] if text.is_a?(Hash)
    return '' if text.nil?

    Govspeak::Document.new(text, sanitize: true).to_html.html_safe
  end

  def a_z_index(letter = 'a')
    ('a'..'z').map { |index_letter|
      tag.li(class: ('active' if index_letter == letter).to_s) do
        link_to index_letter.upcase, a_z_index_path(letter: index_letter)
      end
    }.join.html_safe
  end

  def generate_breadcrumbs(current_page, previous_pages)
    breadcrumbs = previous_pages.map do |title, link|
      tag.li class: 'govuk-breadcrumbs__list-item' do
        link_to title, link, class: 'govuk-breadcrumbs__link'
      end
    end

    breadcrumbs << tag.li(current_page, class: 'govuk-breadcrumbs__list-item',
                                        aria: { current: 'page' })

    tag.nav class: 'govuk-breadcrumbs', aria: { label: 'Breadcrumb' } do
      tag.ol class: 'govuk-breadcrumbs__list' do
        safe_join breadcrumbs, "\n"
      end
    end
  end

  def page_header(heading_text = nil, &block)
    extra_content = block_given? ? capture(&block) : nil

    render 'shared/page_header',
           heading_text: heading_text,
           show_switch_service: is_switch_service_banner_enabled?,
           extra_content: extra_content
  end

  def govuk_header_navigation_item(active_class: '', &block)
    base_class_name = 'govuk-header__navigation-item'
    active_class_name = active_class.present? ? "#{base_class_name}--active" : ''

    tag.li(class: "#{base_class_name} #{active_class_name}", &block)
  end

  def search_active_class
    'active' if action_name == 'search' ||
      (controller_name == 'sections' && action_name == 'index') ||
      controller_name == 'find_commodities'
  end

  def browse_active_class
    'active' if controller_name == 'browse_sections'
  end

  def a_z_active_class
    'active' if controller_name == 'search_references'
  end

  def tools_active_class
    'active' if action_name == 'tools'
  end

  def help_active_class
    'active' if action_name == 'help'
  end

  def updates_active_class
    'active' if controller_name == 'news_items'
  end

  def currency_options
    [['Pound sterling', 'GBP'], %w[Euro EUR]]
  end

  def chapter_forum_url(chapter)
    chapter.forum_url.presence || "https://forum.trade-tariff.service.gov.uk/c/classification/chapter-#{chapter.short_code}"
  end

  def current_url_without_parameters
    request.base_url + request.path
  end

  def pretty_date_range(start_date, end_date)
    pretty_end_date = end_date ? "<br>to #{end_date.to_formatted_s(:rfc822)}" : ''

    (start_date.to_formatted_s(:rfc822) + pretty_end_date).html_safe
  end

  def breadcrumb_link_or_text(parent, child, caption)
    if child.present?
      link_to(caption, parent, class: 'govuk-breadcrumbs__link')
    else
      caption
    end
  end

  def css_heading_size(text)
    if text.length >= 400
      'govuk-heading-s'
    elsif text.length >= 120
      'govuk-heading-m'
    else
      'govuk-heading-l'
    end
  end
end
