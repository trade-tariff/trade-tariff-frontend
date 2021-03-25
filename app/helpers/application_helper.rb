module ApplicationHelper
  def govspeak(text)
    text = text['content'] || text[:content] if text.is_a?(Hash)
    return '' if text.nil?

    Govspeak::Document.new(text, sanitize: true).to_html.html_safe
  end

  def a_z_index(letter = 'a')
    ('a'..'z').map do |index_letter|
      content_tag(:li, class: ('active' if index_letter == letter).to_s) do
        link_to index_letter.upcase, a_z_index_path(letter: index_letter)
      end
    end.join.html_safe
  end

  def breadcrumbs
    return nil if %w(pages errors).exclude?(controller_name)

    crumbs = [
      content_tag(:li, link_to('Home', '/', class: 'govuk-breadcrumbs__link'), class: 'govuk-breadcrumbs__list-item'),
      content_tag(:li, link_to('Business and self-employed', 'https://www.gov.uk/browse/business', class: 'govuk-breadcrumbs__link'), class: 'govuk-breadcrumbs__list-item'),
      content_tag(:li, link_to('Imports and exports', 'https://www.gov.uk/browse/business/imports', class: 'govuk-breadcrumbs__link'), class: 'govuk-breadcrumbs__list-item')
    ]
    content_tag(:div, class: 'govuk-breadcrumbs') do
      content_tag(:ol, crumbs.join('').html_safe, class: 'govuk-breadcrumbs__list', role: 'breadcrumbs')
    end
  end

  def generate_breadcrumbs(current_page, previous_pages)
    crumbs = [
      previous_pages.map do |title, link|
        content_tag(:li, nil, class: 'govuk-breadcrumbs__list-item') {
          link_to(title, link, class: 'govuk-breadcrumbs__link')
        }
      end,
      content_tag(:li, current_page, class: 'govuk-breadcrumbs__list-item', aria: { current: 'page' })
    ]

    content_tag(:div, class: 'govuk-breadcrumbs') { content_tag(:ol, crumbs.join('').html_safe, class: 'govuk-breadcrumbs__list', role: 'breadcrumbs') }
  end

  def govuk_header_navigation_item(active_class = false)
    base_classname = 'govuk-header__navigation-item'
    classname = "#{base_classname} #{active_class ? "#{base_classname}--active" : ''}"
    content_tag(:li, class: classname) { yield }
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

  def currency_options
    [%w[Pound\ sterling GBP], %w[Euro EUR]]
  end

  def chapter_forum_url(chapter)
    if chapter.forum_url.present?
      chapter.forum_url
    else
      "https://forum.trade-tariff.service.gov.uk/c/classification/chapter-#{chapter.short_code}"
    end
  end

  def current_url_without_parameters
    request.base_url + request.path
  end

  private

  def currency
    TradeTariffFrontend::ServiceChooser.currency
  end

  def search_date_in_future_month?
    @search&.date.date >= Date.today.at_beginning_of_month.next_month
  end

  def policy_cookie
    cookie = cookies['cookies_policy']

    cookie.present? ? JSON.parse(cookie) : {}
  end

  def cookie_confirmation_class
    @updated_cookies ? 'show' : 'hide'
  end
end
