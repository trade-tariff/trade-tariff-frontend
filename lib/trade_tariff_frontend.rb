module TradeTariffFrontend
  DEFAULT_ENQUIRIES_EMAIL = 'classification.enquiries@hmrc.gov.uk'.freeze
  DEFAULT_SUPPORT_EMAIL = DEFAULT_ENQUIRIES_EMAIL
  WEBCHAT_BASE_URL = 'https://www.tax.service.gov.uk/ask-hmrc/chat/'.freeze
  # Flagsmith Edge Proxy, reached over Cloud Map rather than its public
  # GOV.UK hostname. Every environment has its own ECS cluster and its own
  # tariff.internal namespace, so the address is the same everywhere and the
  # old per-environment map is unnecessary.
  #
  # The public flags-edge.*.trade-tariff.service.gov.uk names route out
  # through CloudFront and the public ALB, so a server-side flag evaluation
  # made from a frontend ECS task left the VPC and came back in, paying the
  # latency, the egress cost and an avoidable internet dependency on a
  # request path. flagsmith-edge registers in Cloud Map under
  # tariff.internal (see trade-tariff-flagsmith terraform/main.tf), so the
  # task can reach it directly.
  #
  # Plain HTTP on 8000: the upstream edge-proxy image serves no TLS, so this
  # needs no internal CA certificate, unlike the 8443 services.
  FLAGSMITH_EDGE_API_URL = 'http://flagsmith-edge.tariff.internal:8000/api/v1'.freeze

  autoload :Presenter,      'trade_tariff_frontend/presenter'
  autoload :ExperimentUrls, 'trade_tariff_frontend/experiment_urls'
  autoload :RequestCountry, 'trade_tariff_frontend/request_country'
  autoload :RequestCountryMiddleware, 'trade_tariff_frontend/request_country_middleware'
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
