module ApplicationHelper
  include InterceptGuidanceHelper

  def home_path(*args, &block)
    find_commodity_path(*args, &block)
  end

  def home_url(*args, &block)
    find_commodity_url(*args, &block)
  end

  def govspeak(text)
    text = text['content'] || text[:content] if text.is_a?(Hash)
    return '' if text.nil?

    Govspeak::Document.new(text, sanitize: true).to_html.html_safe
  end

  def govspeak_note(text)
    html = govspeak(text)
    html = GoodsNomenclatureCodeLinkifier.new(html).render unless TradeTariffFrontend.production?

    insert_service_links(html).html_safe
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

    tag.nav class: %w[govuk-breadcrumbs govuk-!-display-none-print],
            aria: { label: 'Breadcrumb' } do
      tag.ol class: 'govuk-breadcrumbs__list' do
        safe_join breadcrumbs, "\n"
      end
    end
  end

  def page_header(heading_text = nil, caption_text = nil, &block)
    extra_content = block_given? ? capture(&block) : nil

    render 'shared/page_header',
           heading_text:,
           caption_text:,
           show_switch_service: is_switch_service_banner_enabled?,
           extra_content:
  end

  def service_navigation_active_when(*prefixes)
    normalized_prefixes = prefixes.flatten.compact.filter_map do |prefix|
      cleaned_prefix = prefix.to_s.sub(%r{\A/}, '')
      Regexp.escape(cleaned_prefix) if cleaned_prefix.present?
    end

    # if prefix is news this regex will match:
    # /news
    # /xi/news
    # /uk/news
    # /news/anything-else
    %r{\A/(?:(?:xi|uk)/)?(?:#{normalized_prefixes.join('|')})}
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

  def feedback_path_with_context(options = {})
    feedback_path(feedback_context_params.merge(options))
  end

  def feedback_context_params
    {
      feedback_url: request.original_url,
      feedback_query: feedback_search_query,
      feedback_request_id: feedback_search_request_id,
      feedback_date: feedback_search_date,
    }.compact
  end

  def feedback_search_query
    @search&.q.presence || params[:q].presence
  end

  def feedback_search_request_id
    @search&.request_id.presence || params[:request_id].presence
  end

  def feedback_search_date
    return if params[:invalid_date].present?
    return @search.date.to_fs(:db) if @search&.filtered_by_date?

    feedback_date_from_day_month_year
  end

  def feedback_date_from_day_month_year
    return unless params.values_at(:day, :month, :year).all?(&:present?)

    TariffDate.build(params.permit(:year, :month, :day).to_h).to_fs(:db)
  rescue Date::Error
    nil
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

  def present_from_to(from, to)
    return nil if from.blank?

    from = " From #{from.to_formatted_s(:short)}"

    if to.present?
      "#{from} to #{to.to_formatted_s(:short)}"
    else
      from
    end
  end

  def govuk_date_range(from, to)
    if to.present?
      "#{from.to_date.to_formatted_s(:long)} to #{to.to_date.to_formatted_s(:long)}"
    else
      "From #{from.to_date.to_formatted_s(:long)}"
    end
  end

  def paragraph_if_content(content)
    tag.p(content) if content.present?
  end

  def back_link(url, **options)
    html_attributes = {}
    if options.delete(:javascript)
      html_attributes[:onclick] = 'window.history.go(-1); return false;'
    end

    govuk_back_link(href: url, html_attributes:)
  end

  def glossary_term(term)
    link_to term, glossary_term_path(term.to_s.underscore)
  end

  def link_glossary_terms(content)
    content.gsub %r{\(([A-Z][A-Za-z]+)\)} do |match|
      term = Regexp.last_match.captures[0]

      if Pages::Glossary.pages.include? term.underscore
        "([#{term}](#{glossary_term_path(term.underscore)}))"
      else
        match
      end
    end
  end

  def duty_calculator_link(declarable_code)
    code = divide_commodity_code(declarable_code).join(' ')
    link_description = "work out the duties and taxes applicable to the import of commodity #{code}"
    link_url = import_date_path(commodity_code: declarable_code)

    govuk_link_to link_description, link_url, id: 'duty-calculator-link'
  end

  def month_name_and_year(month, year)
    # Output examples: "March 2022", "2022"
    month.present? ? "#{Date::MONTHNAMES[month.to_i]} #{year}" : year.to_s
  end
end
