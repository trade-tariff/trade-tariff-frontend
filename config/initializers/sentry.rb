Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger]

  config.excluded_exceptions += %w[
    Faraday::ResourceNotFound
    WizardSteps::UnknownStep
    TradeTariffFrontend::FeatureUnavailable
    TradeTariffFrontend::MaintenanceMode
  ]
end
