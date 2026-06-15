ActionDispatch::ExceptionWrapper.rescue_responses.merge!(
  'Faraday::ResourceNotFound' => :not_found,
  'Pages::Glossary::UnknownPage' => :not_found,
  'WizardSteps::UnknownStep' => :not_found,
  'ActionView::MissingTemplate' => :not_found,
  'ActionController::UnknownFormat' => :not_found,
  'ActionDispatch::Http::MimeNegotiation::InvalidType' => :bad_request,
  'ActionDispatch::InvalidParameterError' => :bad_request,
  'ActionDispatch::Http::Parameters::ParseError' => :bad_request,
  'AbstractController::ActionNotFound' => :not_found,
  'URI::InvalidURIError' => :not_found,
  'TradeTariffFrontend::FeatureUnavailable' => :not_found,
  'TradeTariffFrontend::MaintenanceMode' => :service_unavailable,
)
