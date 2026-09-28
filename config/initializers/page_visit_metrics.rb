require_relative '../../lib/page_visit_metrics'

unless Rails.env.test?
  Rails.application.config.to_prepare do
    PageVisitMetrics.subscribe!
  end
end
