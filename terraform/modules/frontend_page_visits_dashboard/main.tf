locals {
  guide_url = "https://github.com/trade-tariff/trade-tariff-frontend/blob/main/docs/frontend-page-visits-dashboard.md"
  puma_url  = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=Puma-frontend-${var.environment}"
  charts = [
    { query = "cohorts", title = "Browser sessions by request frequency", view = "pie", x = 0, y = 6, width = 12 },
    { query = "pages", title = "Share of requests by activity", view = "pie", x = 12, y = 6, width = 12 },
    { query = "coverage", title = "Requests with and without a session identifier", view = "pie", x = 0, y = 12, width = 12 },
    { query = "volume", title = "Requests per hour by activity", view = "timeSeries", x = 0, y = 18, width = 24 },
    { query = "distribution", title = "Requests per browser session (21 means 21+)", view = "bar", x = 12, y = 12, width = 12 },
    { query = "behaviour", title = "Share of requests by activity within each frequency group (%)", view = "table", x = 0, y = 24, width = 24 },
    { query = "responses", title = "Page responses per hour: includes redirects and errors", view = "timeSeries", x = 0, y = 30, width = 24 },
    { query = "popular_pages", title = "Most visited pages and form submissions (top 20)", view = "table", x = 0, y = 36, width = 24 },
    { query = "first_last", title = "First and last recorded pages in this period (top 20, not entry/exit points)", view = "table", x = 0, y = 42, width = 24 },
  ]
}

resource "aws_cloudwatch_dashboard" "page_visits" {
  dashboard_name = "Frontend-Page-Visits-${var.environment}"
  dashboard_body = jsonencode({
    start          = "-PT24H"
    periodOverride = "inherit"
    widgets = concat([
      {
        type = "text", x = 0, y = 0, width = 24, height = 6
        properties = {
          markdown = join("\n\n", [
            "# Frontend Page Visits - ${var.environment}",
            "**Understand how the tariff is used.** Explore which activities receive the most requests and how activity varies between browser sessions in the selected window.",
            "**Start with coverage.** Requests without a session identifier appear in activity totals but not session-based reports. The frequency pie counts sessions; the activity pie counts requests.",
            "**Frequency groups:** Low: 1-${local.frequency_thresholds.low_max} requests; Medium: ${local.frequency_thresholds.low_max + 1}-${local.frequency_thresholds.regular_max}; High: ${local.frequency_thresholds.regular_max + 1}+. These provisional thresholds describe activity in this period, not experience or expertise.",
            "**Reading the figures:** browser sessions are not people. Requests include refreshes, form submissions, redirects and errors, so they are not exact page-view counts. Changing the period or resetting a session can change its group. Empty charts do not necessarily mean no activity.",
            "Prefer manual refresh to limit query costs. [Counting rules and limitations](${local.guide_url}) | [Service performance dashboard](${local.puma_url})",
          ])
        }
      }
      ], [for chart in local.charts : {
        type = "log", x = chart.x, y = chart.y, width = chart.width, height = 6
        properties = {
          title   = chart.title
          region  = var.region
          view    = chart.view
          stacked = false
          query   = trimspace(local.queries[chart.query])
        }
    }])
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
