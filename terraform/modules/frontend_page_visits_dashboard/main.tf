locals {
  guide_url = "https://github.com/trade-tariff/trade-tariff-frontend/blob/main/docs/frontend-page-visits-dashboard.md"
  puma_url  = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=Puma-frontend-${var.environment}"
  namespace = local.catalogue.namespace
  service   = local.catalogue.service
  metric    = local.catalogue.metric
  period    = 3600

  metric_base    = [local.namespace, local.metric, "Environment", var.environment, "Service", local.service]
  activity_color = { for activity in local.catalogue.activities : activity.id => activity.color }
  tariff_color = {
    "BrowseSectionsController#index" = local.activity_color["browse"]
    "SectionsController#show"        = "#9ecae1"
    "ChaptersController#show"        = "#6baed6"
    "HeadingsController#show"        = "#c5b0d5"
    "SubheadingsController#show"     = "#17becf"
    "CommoditiesController#show"     = local.activity_color["commodity"]
  }

  activity_metrics = [for activity in local.catalogue.activities : concat(local.metric_base, ["Activity", activity.label, {
    stat = "Sum", id = activity.id, label = activity.label, color = activity.color
  }])]
  activity_detail_metrics = [for activity in local.catalogue.activities : concat(local.metric_base, ["Activity", activity.label, {
    stat = "Sum", id = activity.id, label = activity.label, color = activity.color
  }]) if activity.id != "other"]
  tariff_metrics = [for key in local.tariff_page_keys : concat(local.metric_base, ["TariffPage", local.page_names[key].name, {
    stat = "Sum", id = "tariff_${replace(replace(lower(key), "::", "_"), "#", "_")}", label = local.page_names[key].name, color = local.tariff_color[key]
  }])]
  status_metrics = [for status in local.catalogue.statuses : concat(local.metric_base, ["StatusClass", status.label, {
    stat = "Sum", id = status.id, label = status.label, color = status.color
  }])]
  status_sources = [for status in local.catalogue.statuses : concat(local.metric_base, ["StatusClass", status.label, {
    stat = "Sum", id = status.id, visible = false
  }])]

  session_sources = [
    concat(local.metric_base, ["SessionCoverage", local.catalogue.coverage.present, { stat = "Sum", id = "with_session_id", visible = false }]),
    concat(local.metric_base, ["SessionCoverage", local.catalogue.coverage.missing, { stat = "Sum", id = "missing_session_id", visible = false }]),
  ]
  mapping_sources = [
    concat(local.metric_base, ["PageMapping", local.catalogue.mapping.mapped, { stat = "Sum", id = "mapped_pages", visible = false }]),
    concat(local.metric_base, ["PageMapping", local.catalogue.mapping.unmapped, { stat = "Sum", id = "unmapped_pages", visible = false }]),
  ]
  observed_session_requests = "FILL(with_session_id,0)+FILL(missing_session_id,0)"
  observed_mapped_requests  = "FILL(mapped_pages,0)+FILL(unmapped_pages,0)"
  observed_status_requests  = join("+", [for status in local.catalogue.statuses : "FILL(${status.id},0)"])

  log_widgets = [
    { title = "Browser sessions by request frequency", query = "cohorts", view = "bar", x = 12, y = 12, width = 12, height = 6 },
    { title = "Sessions by request count (21 means 21 or more)", query = "distribution", view = "bar", x = 0, y = 18, width = 12, height = 6 },
    { title = "Share of requests by activity within each frequency group", query = "behaviour", view = "table", x = 0, y = 46, width = 24, height = 8 },
    { title = "First and last observed page types (top 20, not entry or exit points)", query = "first_last", view = "table", x = 0, y = 66, width = 24, height = 8 },
  ]
}

resource "aws_cloudwatch_dashboard" "page_visits" {
  dashboard_name = "Frontend-Page-Visits-${var.environment}"
  dashboard_body = jsonencode({
    start          = "-PT24H"
    periodOverride = "inherit"
    widgets = concat(
      [
        {
          type = "text", x = 0, y = 0, width = 24, height = 8
          properties = {
            markdown = join("\n\n", [
              "# Frontend Page Visits - ${var.environment}",
              "**Understand how the tariff is used.** Request charts are container metrics. Session charts still scan frontend logs for the selected window.",
              "**Start with coverage.** Session-ID coverage and page-name coverage are separate. Requests without a session identifier are in activity totals but not session reports. A missing metric series means no matching event was recorded, not a failed query. A coverage number shows zero for the missing side only when the other side has data in the selected window.",
              "**Frequency groups:** Low: 1-${local.frequency_thresholds.low_max} requests; Medium: ${local.frequency_thresholds.low_max + 1}-${local.frequency_thresholds.regular_max}; High: ${local.frequency_thresholds.regular_max + 1}+. These provisional thresholds describe activity in this period, not experience or expertise. The one-request bar dominates the distribution; use the frequency table for the group counts.",
              "**Reading the figures:** browser sessions are not people. Requests include refreshes, form submissions, redirects and errors, so they are not exact page-view counts. Changing the period or resetting a session can change its group. Metric history starts when collection is deployed. Empty charts do not necessarily mean no activity, and a gap is not zero.",
              "Metrics count one application event per request. A repeated log line can double-count a metric. Session charts still collapse duplicate request IDs. The page-family bar shows families that reported during the last two weeks, so an older selected window can omit a quiet family. Prefer manual refresh for the four log charts. [Counting rules and limitations](${local.guide_url}) | [Service performance dashboard](${local.puma_url})",
            ])
          }
        },
        {
          type = "metric", x = 0, y = 8, width = 4, height = 4
          properties = {
            title   = "Requests with a session ID", region = var.region, view = "singleValue", sparkline = false, setPeriodToTimeRange = true
            metrics = [concat(local.metric_base, ["SessionCoverage", local.catalogue.coverage.present, { stat = "Sum", label = local.catalogue.coverage.present }])]
          }
        },
        {
          type = "metric", x = 4, y = 8, width = 4, height = 4
          properties = {
            title = "Requests missing a session ID", region = var.region, view = "singleValue", sparkline = false, setPeriodToTimeRange = true
            metrics = concat(local.session_sources, [[{
              expression = "IF(${local.observed_session_requests}>0,FILL(missing_session_id,0))"
              id         = "missing_display"
              label      = local.catalogue.coverage.missing
            }]])
          }
        },
        {
          type = "metric", x = 8, y = 8, width = 4, height = 4
          properties = {
            title = "Session ID coverage (%)", region = var.region, view = "singleValue", sparkline = false, setPeriodToTimeRange = true
            metrics = concat(local.session_sources, [[{
              expression = "IF(${local.observed_session_requests}>0,100*FILL(with_session_id,0)/(${local.observed_session_requests}))"
              id         = "session_coverage"
              label      = "Coverage"
            }]])
            yAxis = { left = { min = 0, max = 100, showUnits = false } }
          }
        },
        {
          type = "metric", x = 12, y = 8, width = 4, height = 4
          properties = {
            title   = "Mapped page requests", region = var.region, view = "singleValue", sparkline = false, setPeriodToTimeRange = true
            metrics = [concat(local.metric_base, ["PageMapping", local.catalogue.mapping.mapped, { stat = "Sum", label = local.catalogue.mapping.mapped }])]
          }
        },
        {
          type = "metric", x = 16, y = 8, width = 4, height = 4
          properties = {
            title = "Unmapped page requests", region = var.region, view = "singleValue", sparkline = false, setPeriodToTimeRange = true
            metrics = concat(local.mapping_sources, [[{
              expression = "IF(${local.observed_mapped_requests}>0,FILL(unmapped_pages,0))"
              id         = "unmapped_display"
              label      = local.catalogue.mapping.unmapped
            }]])
          }
        },
        {
          type = "metric", x = 20, y = 8, width = 4, height = 4
          properties = {
            title = "Page-name coverage (%)", region = var.region, view = "singleValue", sparkline = false, setPeriodToTimeRange = true
            metrics = concat(local.mapping_sources, [[{
              expression = "IF(${local.observed_mapped_requests}>0,100*FILL(mapped_pages,0)/(${local.observed_mapped_requests}))"
              id         = "mapping_coverage"
              label      = "Mapped"
            }]])
            yAxis = { left = { min = 0, max = 100, showUnits = false } }
          }
        },
        {
          type = "metric", x = 0, y = 12, width = 12, height = 6
          properties = {
            title   = "Requests by activity (selected range)", region = var.region, view = "bar", stacked = false, setPeriodToTimeRange = true
            metrics = local.activity_metrics
            legend  = { position = "bottom" }
            yAxis   = { left = { label = "Requests", showUnits = false, min = 0 } }
          }
        },
        {
          type = "metric", x = 0, y = 24, width = 24, height = 6
          properties = {
            title   = "Requests per hour by activity", region = var.region, view = "timeSeries", stacked = true, period = local.period
            metrics = local.activity_metrics
            legend  = { position = "bottom" }
            yAxis   = { left = { label = "Requests", showUnits = false, min = 0 } }
          }
        },
        {
          type = "metric", x = 0, y = 30, width = 24, height = 6
          properties = {
            title   = "Requests per hour by activity, excluding Other pages", region = var.region, view = "timeSeries", stacked = false, period = local.period
            metrics = local.activity_detail_metrics
            legend  = { position = "bottom" }
            yAxis   = { left = { label = "Requests", showUnits = false, min = 0 } }
          }
        },
        {
          type = "metric", x = 12, y = 18, width = 12, height = 6
          properties = {
            title   = "Tariff page requests (selected range)", region = var.region, view = "bar", stacked = false, setPeriodToTimeRange = true
            metrics = local.tariff_metrics
            legend  = { position = "bottom" }
            yAxis   = { left = { label = "Requests", showUnits = false, min = 0 } }
          }
        },
        {
          type = "metric", x = 0, y = 36, width = 12, height = 6
          properties = {
            title   = "Tariff page requests per hour", region = var.region, view = "timeSeries", stacked = false, period = local.period
            metrics = local.tariff_metrics
            legend  = { position = "bottom" }
            yAxis   = { left = { label = "Requests", showUnits = false, min = 0 } }
          }
        },
        {
          type = "metric", x = 12, y = 36, width = 12, height = 6
          properties = {
            title   = "Page responses per hour, including redirects and errors", region = var.region, view = "timeSeries", stacked = true, period = local.period
            metrics = local.status_metrics
            legend  = { position = "bottom" }
            yAxis   = { left = { label = "Requests", showUnits = false, min = 0 } }
          }
        },
      ],
      [for index, status in local.catalogue.statuses : {
        type = "metric", x = index * 6, y = 42, width = 6, height = 4
        properties = {
          title = "${status.label} (selected range)", region = var.region, view = "singleValue", sparkline = false, setPeriodToTimeRange = true
          metrics = concat(local.status_sources, [[{
            expression = "IF(${local.observed_status_requests}>0,FILL(${status.id},0))"
            id         = "${status.id}_display"
            label      = status.label
            color      = status.color
          }]])
        }
      }],
      [
        {
          type = "metric", x = 0, y = 54, width = 24, height = 12
          properties = {
            title = "Requested page types that reported in the last two weeks", region = var.region, view = "bar", stacked = false, setPeriodToTimeRange = true
            metrics = [[
              {
                expression = "SEARCH('{${local.namespace},Environment,Service,Page} MetricName=\"${local.metric}\" Environment=\"${var.environment}\" Service=\"${local.service}\"', 'Sum', ${local.period})"
                id         = "page_families"
              }
            ]]
            legend = { position = "hidden" }
            yAxis  = { left = { label = "Requests", showUnits = false, min = 0 } }
          }
        },
      ],
      [for chart in local.log_widgets : {
        type = "log", x = chart.x, y = chart.y, width = chart.width, height = chart.height
        properties = {
          title   = chart.title
          region  = var.region
          view    = chart.view
          stacked = false
          query   = trimspace(local.queries[chart.query])
        }
      }]
    )
  })
}

output "dashboard_name" {
  description = "Frontend page visits dashboard name."
  value       = aws_cloudwatch_dashboard.page_visits.dashboard_name
}

output "dashboard_url" {
  description = "Frontend page visits dashboard URL."
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.page_visits.dashboard_name}"
}
