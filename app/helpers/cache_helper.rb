module CacheHelper
  def cache_key
    [TradeTariffFrontend::ServiceChooser.cache_prefix, @tariff_last_updated, TradeTariffFrontend.revision].join('/')
  end
end
