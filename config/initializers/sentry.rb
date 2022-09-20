Sentry.init do |config|
  config.rails.report_rescued_exceptions = true

  config.breadcrumbs_logger = [:active_support_logger]
end
