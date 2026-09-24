module CacheHelper
  CACHE_EXCLUDED_PARAMS = %w[request_id].freeze

  def cache_key
    [TradeTariffFrontend::ServiceChooser.cache_prefix, TradeTariffFrontend.revision].join('/')
  end

  def commodity_cache_key
    [
      'commodities#show',
      cache_key,
      meursing_lookup_result.meursing_additional_code_id,
      commodity_search_navigation_cache_key,
      cache_params.sort.map { |_, v| v }.compact.join('/'),
    ].compact
  end

  def commodity_search_navigation_cache_key
    return if @show_commodity_search_link.nil?

    @show_commodity_search_link ? 'guided-search-link' : 'shared-search'
  end

  def heading_cache_key
    [
      'headings#show',
      cache_key,
      cache_params.sort.map { |_, v| v }.compact.join('/'),
    ].compact
  end

  def cache_params
    params.to_unsafe_h.except(*CACHE_EXCLUDED_PARAMS)
  end

  def resilient_cache_if(condition, key, &block)
    cache_if(condition, key, &block)
  rescue Zlib::DataError, Timeout::Error, Timeout::ExitException => e
    Rails.logger.error("Cache deserialization error for key #{key}: #{e.class} - #{e.message}")

    Rails.cache.delete(key)
    capture(&block)
  end
end
