ActionDispatch::ExceptionWrapper.rescue_responses.merge!(
  'Faraday::ResourceNotFound' => :not_found,
  'WizardSteps::UnknownStep' => :not_found,
  'ActionView::MissingTemplate' => :not_found,
  'ActionController::UnknownFormat' => :not_found,
  'AbstractController::ActionNotFound' => :not_found,
  'URI::InvalidURIError' => :not_found,
  'TradeTariffFrontend::FeatureUnavailable' => :not_found,
  'TradeTariffFrontend::MaintenanceMode' => :service_unavailable,
)
