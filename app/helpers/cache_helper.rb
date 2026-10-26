module CacheHelper
  # The only params that change what a commodity or heading page shows.
  # Any other param (utm_*, _ga, fbclid, request_id, ...) is ignored, so it can
  # neither split the cache key nor be copied into the cached HTML.
  CACHE_KEY_PARAM_NAMES = %w[id country t day month year].freeze

  def cache_key
    [TradeTariffFrontend::ServiceChooser.cache_prefix, TradeTariffFrontend.revision].join('/')
  end

  def commodity_cache_key(show_commodity_search_link: nil)
    [
      'commodities#show',
      cache_key,
      meursing_lookup_result.meursing_additional_code_id,
      commodity_search_navigation_cache_key(show_commodity_search_link:),
      cache_params_key,
    ].compact
  end

  def commodity_search_navigation_cache_key(show_commodity_search_link: nil)
    return if show_commodity_search_link.nil?

    show_commodity_search_link ? 'guided-search-link' : 'shared-search'
  end

  def heading_cache_key
    [
      'headings#show',
      cache_key,
      cache_params_key,
    ].compact
  end

  # Only plain day, month and year dates are cached. The as_of(1i), as_of(day)
  # forms render other date fields and links, so those requests skip the cache.
  def canonical_date_params?
    params.keys.none? { |name| name.start_with?('as_of') }
  end

  # Query params that are safe to copy into links inside HTML. The date and the
  # country come from the nested search params when present, as the controller
  # does, so links keep the same date for requests that are not cached.
  def cacheable_query_params(query_parameters = request.query_parameters)
    query_parameters = query_parameters.to_h.stringify_keys
    nested_search = query_parameters['search']
    search_source = nested_search.is_a?(Hash) ? nested_search.stringify_keys : query_parameters

    query_parameters
      .slice('t')
      .merge(search_source.slice('country'))
      .merge(TariffDate.normalized_date_attributes(search_source))
  end

  # to_query escapes every name and value, so a value that contains "/", "&" or
  # "=" cannot look like another param. Blank dates stay in the key because the
  # date fields render them blank instead of as today.
  def cache_params_key
    params.to_unsafe_h.slice(*CACHE_KEY_PARAM_NAMES).compact.to_query
  end

  def resilient_cache_if(condition, key, &block)
    cache_if(condition, key, &block)
  rescue Zlib::DataError, Timeout::Error, Timeout::ExitException => e
    Rails.logger.error("Cache deserialization error for key #{key}: #{e.class} - #{e.message}")

    Rails.cache.delete(key)
    capture(&block)
  end
end
