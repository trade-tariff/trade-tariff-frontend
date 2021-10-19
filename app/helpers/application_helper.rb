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
    crumbs = [
      previous_pages.map do |title, link|
        tag.li(nil, class: 'govuk-breadcrumbs__list-item') do
          link_to(title, link, class: 'govuk-breadcrumbs__link')
        end
      end,
      tag.li(current_page, class: 'govuk-breadcrumbs__list-item', aria: { current: 'page' }),
    ]

    tag.div(class: 'govuk-breadcrumbs') { tag.ol(crumbs.join('').html_safe, class: 'govuk-breadcrumbs__list', role: 'breadcrumbs') }
  end

  def govuk_header_navigation_item(active_class = false)
    base_classname = 'govuk-header__navigation-item'
    classname = "#{base_classname} #{active_class ? "#{base_classname}--active" : ''}"
    tag.li(class: classname) { yield }
  end

  def search_active_class
    'active' if params[:action] == 'search' || (params[:controller] == 'sections' && params[:action] == 'index')
  end

  def a_z_active_class
    'active' if params[:controller] == 'search_references'
  end

  def tools_active_class
    'active' if params[:action] == 'tools'
  end

  def help_active_class
    'active' if params[:action] == 'help'
  end

  def currency_options
    [%w[Pound\ sterling GBP], %w[Euro EUR]]
  end

  def chapter_forum_url(chapter)
    chapter.forum_url.presence || "https://forum.trade-tariff.service.gov.uk/c/classification/chapter-#{chapter.short_code}"
  end

  def current_url_without_parameters
    request.base_url + request.path
  end

  def pretty_date_range(start_date, end_date)
    pretty_end_date = end_date ? "to #{end_date.to_formatted_s(:rfc822)}" : ''

    start_date.to_formatted_s(:rfc822) + pretty_end_date
  end

  private

  def search_date_in_future_month?
    @search&.date.date >= Date.today.at_beginning_of_month.next_month
  end
end
