Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger]

  config.excluded_exceptions += %w[
    Faraday::ResourceNotFound
  ]
end
