module CacheHelper
  CACHE_EXCLUDED_PARAMS = %w[request_id].freeze

  def cache_key
    [TradeTariffFrontend::ServiceChooser.cache_prefix, @tariff_last_updated, TradeTariffFrontend.revision].join('/')
  end

  def commodity_cache_key
    [
      'commodities#show',
      cache_key,
      meursing_lookup_result.meursing_additional_code_id,
      cache_params.sort.map { |_, v| v }.compact.join('/'),
    ].compact
  end

  def cache_params
    params.to_unsafe_h.except(*CACHE_EXCLUDED_PARAMS)
  end
end
