module CacheHelper
  # The only query params that change what a commodity or heading page shows.
  # Any other param (utm_*, _ga, fbclid, request_id, ...) is ignored, so it can
  # neither split the cache key nor be copied into links inside cached HTML.
  CACHEABLE_QUERY_PARAM_NAMES = %w[day month year country t].freeze
  CACHEABLE_KEY_PARAM_NAMES = (%w[id] + CACHEABLE_QUERY_PARAM_NAMES).freeze

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
    query_parameters.to_h.stringify_keys.slice(*CACHEABLE_QUERY_PARAM_NAMES)
  end

  # Includes the param names, so ?country=US and ?t=US give different keys.
  # The country is upper-cased because the backend call upper-cases it too.
  def cache_params_key
    key_params = params.to_unsafe_h.slice(*CACHEABLE_KEY_PARAM_NAMES)
    key_params['country'] = key_params['country'].to_s.upcase if key_params.key?('country')

    key_params.sort.map { |name, value| "#{name}=#{value}" }.join('/')
  end

  def resilient_cache_if(condition, key, &block)
    cache_if(condition, key, &block)
  rescue Zlib::DataError, Timeout::Error, Timeout::ExitException => e
    Rails.logger.error("Cache deserialization error for key #{key}: #{e.class} - #{e.message}")

    Rails.cache.delete(key)
    capture(&block)
  end
end
