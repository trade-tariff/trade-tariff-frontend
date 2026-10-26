module CacheHelper
  # The only params that change what a commodity or heading page shows.
  # Any other param (utm_*, _ga, fbclid, request_id, ...) is ignored, so it can
  # neither split the cache key nor be copied into the cached HTML.
  # The date is read through TariffDate, so day/month/year and the as_of(1i)
  # style parts give the same key and the same links.
  CACHEABLE_PLAIN_PARAM_NAMES = %w[country t].freeze

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

  # Query params that are safe to copy into links inside cached HTML.
  def cacheable_query_params(query_parameters = request.query_parameters)
    query_parameters = query_parameters.to_h.stringify_keys

    query_parameters
      .slice(*CACHEABLE_PLAIN_PARAM_NAMES)
      .merge(TariffDate.normalized_date_attributes(query_parameters))
  end

  # Built from the same params as the links. to_query escapes every name and
  # value, so a value that contains "/", "&" or "=" cannot look like another param.
  def cache_params_key
    all_params = params.to_unsafe_h

    cacheable_query_params(all_params).merge('id' => all_params['id']).compact.to_query
  end

  def resilient_cache_if(condition, key, &block)
    cache_if(condition, key, &block)
  rescue Zlib::DataError, Timeout::Error, Timeout::ExitException => e
    Rails.logger.error("Cache deserialization error for key #{key}: #{e.class} - #{e.message}")

    Rails.cache.delete(key)
    capture(&block)
  end
end
