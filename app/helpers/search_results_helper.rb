module SearchResultsHelper
  def descriptions_with_other_handling(commodity)
    return sanitize commodity.description.to_s unless commodity.description.to_s.match(/^other/i)

    ancestor_descriptions = commodity.ancestor_descriptions.reverse

    descriptions = []

    ancestor_descriptions.each do |ancestor_description|
      descriptions.unshift(ancestor_description.to_s)

      break unless ancestor_description.to_s.match(/^other/i)
    end

    descriptions[-1] = tag.strong(descriptions.last)
    descriptions = descriptions.join(' > ')

    sanitize descriptions
  end

  def toggle_beta_search_inset_text
    if beta_search_enabled?
      switch_link = link_to('switch back to legacy search', toggle_beta_search_path)

      t('search.beta_search.inset_text_enabled_html', switch_link:)
    else
      switch_link = link_to('Use the Beta Search', toggle_beta_search_path)

      t('search.beta_search.inset_text_disabled_html', switch_link:)
    end
  end

  def filtered_link_for(filterable)
    path_options = filtered_url_options_for(filterable.filter)
    path = perform_search_path(path_options)
    link_html = link_to(filterable.display_name, path)

    link_html += " (#{filterable.count})"
    link_html
  end

  def uncorrected_search_link_for(original_search_query)
    path_options = uncorrected_url_options
    path = perform_search_path(path_options)

    link_to(original_search_query, path)
  end

  def disapply_filter_link_for(filterable)
    path_options = disapply_url_options_for(filterable.filterable_key.to_sym)
    path = perform_search_path(path_options)

    link_to("[x] #{filterable.filterable_display_name}", path, class: 'facet-classifications-tag')
  end

  def applied_filter_classifications
    @applied_filter_classifications ||= @filters.to_h.symbolize_keys.each_with_object([]) { |(filter, classification), acc|
      filterable = case filter
                   when :heading_id
                     @search_result.heading_statistics.find_by_heading(classification)
                   else

                     @search_result.classification_for(filter, classification)
                   end
      acc << filterable if filterable.present?
    }.sort_by(&:filterable_value)
  end

  def unapplied_filter_classifications
    @search_result.facet_filter_statistics.reject do |facet_filter_statistic|
      facet_filter_statistic.facet.in?(applied_filter_classifications.map(&:filterable_key))
    end
  end

  def ancestor_links(hit, css_class: nil)
    ancestors = hit.ancestors[1..].presence || []

    ancestors.map do |good_nomenclature|
      link_to(good_nomenclature.formatted_description, polymorphic_path(good_nomenclature), class: css_class)
    end
  end

  private

  def uncorrected_url_options
    filters = @filters.to_h.symbolize_keys
    options = sanitized_url_options
    options.merge!(spell: '0')
    options.merge!(q: @query)
    options.deep_merge!(filter: filters)
    options
  end

  def filtered_url_options_for(filter)
    filters = @filters.to_h.symbolize_keys

    options = sanitized_url_options
    options.merge!(q: @query)
    options.deep_merge!(filter: filters)
    options.deep_merge!(filter:)
    options
  end

  def disapply_url_options_for(filterable)
    filters = @filters.to_h.symbolize_keys
    filters = filters.except(filterable)

    options = sanitized_url_options
    options.merge!(q: @query)
    options.deep_merge!(filter: filters)
    options
  end

  def sanitized_url_options
    options = controller.url_options.deep_dup
    options.delete(:year)
    options.delete(:month)
    options.delete(:day)
    options.delete(:country)
    options
  end
end
