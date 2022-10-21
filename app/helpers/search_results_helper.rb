module SearchResultsHelper
  def filtered_link_for(filterable)
    path_options = filtered_url_options_for(filterable.filter)
    path = perform_search_path(path_options)
    link_html = link_to(filterable.display_name, path)

    link_html += " (#{filterable.count})"
    link_html
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
