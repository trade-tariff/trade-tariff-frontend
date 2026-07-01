module TradeTariffFrontend
  DEFAULT_ENQUIRIES_EMAIL = 'classification.enquiries@hmrc.gov.uk'.freeze
  DEFAULT_SUPPORT_EMAIL = DEFAULT_ENQUIRIES_EMAIL
  WEBCHAT_BASE_URL = 'https://www.tax.service.gov.uk/ask-hmrc/chat/'.freeze
  FLAGSMITH_API_URLS = {
    'development' => 'https://flags-edge.dev.trade-tariff.service.gov.uk/api/v1',
    'staging' => 'https://flags-edge.staging.trade-tariff.service.gov.uk/api/v1',
    'production' => 'https://flags-edge.trade-tariff.service.gov.uk/api/v1',
  }.freeze

  autoload :Presenter,      'trade_tariff_frontend/presenter'
  autoload :ServiceChooser, 'trade_tariff_frontend/service_chooser'
  autoload :ViewContext,    'trade_tariff_frontend/view_context'

  require_relative 'trade_tariff_frontend/config'
  extend Config

  def self.revision
    @revision ||= `cat REVISION 2>/dev/null || echo 'development'`.strip
  end

  class FeatureUnavailable < StandardError; end
  class MaintenanceMode < StandardError; end
end
