module CacheHelper
  def cache_key
    [TradeTariffFrontend::ServiceChooser.cache_prefix, @tariff_last_updated, TradeTariffFrontend.revision].join('/')
  end

  def commodity_cache_key
    [
      'commodities#show',
      cache_key,
      meursing_lookup_result.meursing_additional_code_id,
      params.to_unsafe_h.sort.map { |_, v| v }.compact.join('/'),
    ].compact
  end
end
