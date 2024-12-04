Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  config.excluded_exceptions += %w[
    Faraday::ResourceNotFound
    WizardSteps::UnknownStep
    TradeTariffFrontend::FeatureUnavailable
    TradeTariffFrontend::MaintenanceMode
  ]

  config.traces_sample_rate = 1.0

  config.profiles_sample_rate = 1.0
end
