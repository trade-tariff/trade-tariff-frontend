module SearchResultsHelper
  def filtered_link_for(facet_classification_statistic)
    path_options = filtered_url_options_for(facet_classification_statistic.filter)
    path = perform_search_path(path_options)
    link_html = link_to(facet_classification_statistic.classification.humanize, path)

    link_html += " (#{facet_classification_statistic.count})"
    link_html
  end

  def disapply_filter_link_for(facet_classification_statistic)
    path_options = disapply_url_options_for(facet_classification_statistic.facet.to_sym)
    path = perform_search_path(path_options)

    link_to("[x] #{facet_classification_statistic.classification.humanize}", path, class: 'facet-classifications-tag')
  end

  def applied_filter_classifications
    @filters.to_h.symbolize_keys.each_with_object([]) do |(filter, classification), acc|
      facet_classification_statistic = @search_result.classification_for(filter, classification)
      acc << facet_classification_statistic if facet_classification_statistic.present?
    end
  end

  private

  def filtered_url_options_for(filter)
    filters = @filters.to_h.symbolize_keys

    options = sanitized_url_options
    options.merge!(q: @query)
    options.deep_merge!(filter: filters)
    options.deep_merge!(filter:)
    options
  end

  def disapply_url_options_for(facet)
    filters = @filters.to_h.symbolize_keys
    filters = filters.except(facet)

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
