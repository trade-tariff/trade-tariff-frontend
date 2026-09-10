locals {
  guide_url = "https://github.com/trade-tariff/trade-tariff-frontend/blob/main/docs/frontend-page-visits-dashboard.md"
  puma_url  = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=Puma-frontend-${var.environment}"
  charts = [
    { query = "cohorts", title = "User frequency groups (browser sessions)", view = "pie", x = 0, y = 6, width = 12 },
    { query = "pages", title = "Most visited pages: page-type share", view = "pie", x = 12, y = 6, width = 12 },
    { query = "coverage", title = "Page requests: session-ID coverage", view = "pie", x = 0, y = 12, width = 12 },
    { query = "volume", title = "Page requests per hour, by page type", view = "timeSeries", x = 0, y = 18, width = 24 },
    { query = "distribution", title = "Visits per browser session (21 means 21+)", view = "bar", x = 12, y = 12, width = 12 },
    { query = "behaviour", title = "Behaviour by frequency group: request shares (%)", view = "table", x = 0, y = 24, width = 24 },
    { query = "responses", title = "Page responses per hour: includes redirects and errors", view = "timeSeries", x = 0, y = 30, width = 24 },
    { query = "popular_pages", title = "Most visited pages and form submissions (top 20)", view = "table", x = 0, y = 36, width = 24 },
    { query = "first_last", title = "First and last observed pages (top 20, not entry/exit proof)", view = "table", x = 0, y = 42, width = 24 },
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
            "**Product: start here:** check session-ID coverage, then the frequency and activity pies. Groups count browser sessions, not people; activities count requests, including Other. After a logging deployment, check a recent window: older requests may have no session ID.",
            "**Frequency in the selected window:** Low 1-${local.frequency_thresholds.low_max}; Regular ${local.frequency_thresholds.low_max + 1}-${local.frequency_thresholds.regular_max}; High ${local.frequency_thresholds.regular_max + 1}+. Provisional counts, not expertise. Window changes and session resets change grouping. Missing IDs are excluded from groups, not counted as low frequency.",
            "**Page visits:** public HTML controller requests, including refreshes, submissions, redirects and errors; duplicate HTTP IDs count once. Known bots/auth routes excluded. No data is not zero; requests are not proof of visible views. First/last pages are window-limited, not entry/exit proof.",
            "**Cost:** prefer manual refresh; each refresh runs nine log queries. [Definitions, exclusions and coverage](${local.guide_url}) | [Puma operations](${local.puma_url})",
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
