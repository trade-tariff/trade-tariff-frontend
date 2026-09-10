mock_provider "aws" {}

variables {
  environment = "staging"
  region      = "eu-west-2"
}

run "page_visits_dashboard" {
  command = plan

  assert {
    condition     = aws_cloudwatch_dashboard.page_visits.dashboard_name == "Frontend-Page-Visits-staging"
    error_message = "The page visits dashboard must be isolated by environment."
  }

  assert {
    condition = alltrue([
      for widget in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets :
      strcontains(widget.properties.query, "SOURCE 'platform-logs-staging'") &&
      strcontains(widget.properties.query, "ecs\\/frontend\\/") &&
      strcontains(widget.properties.query, "jsonParse(request_json) as request") &&
      strcontains(widget.properties.query, "request.format = \"html\"") &&
      strcontains(widget.properties.query, "by request.request_id")
      if widget.type == "log"
    ])
    error_message = "All reports must select frontend HTML requests and collapse duplicate request records."
  }

  assert {
    condition = alltrue([
      for widget in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets :
      strcontains(widget.properties.query, "fields bin(1h) as hourly_bin") &&
      strcontains(widget.properties.query, "earliest(hourly_bin) as request_hour") &&
      can(regex("\\| stats [^|]+by Hour,", widget.properties.query))
      if widget.type == "log" && try(widget.properties.view, "") == "timeSeries"
    ])
    error_message = "Time-series queries must carry the hourly bin through request deduplication without reintroducing @timestamp."
  }

  assert {
    condition = alltrue([
      for query in values(local.queries) : length(regexall("\\| stats ", query)) <= 10
    ])
    error_message = "Queries must stay within the documented maximum of ten stats commands."
  }

  assert {
    condition = (
      strcontains(local.cohort_expression, "visits <= ${local.frequency_thresholds.low_max}") &&
      strcontains(local.cohort_expression, "visits <= ${local.frequency_thresholds.regular_max}") &&
      local.frequency_thresholds.low_max > 0 &&
      local.frequency_thresholds.regular_max > local.frequency_thresholds.low_max
    )
    error_message = "Cohort queries must use ordered, inclusive thresholds from the single configuration local."
  }

  assert {
    condition = (
      strcontains(local.queries.cohorts, "filter not isblank(session_id)") &&
      strcontains(local.queries.cohorts, "by session_id") &&
      strcontains(local.queries.cohorts, "count(*) as Sessions by `Frequency group`") &&
      strcontains(local.queries.coverage, "Missing ID")
    )
    error_message = "Cohorts must count sessions, with uncorrelated requests visible separately rather than classified as low-frequency."
  }

  assert {
    condition = (
      strcontains(local.queries.pages, "count(*) as Requests by Activity") &&
      !strcontains(local.queries.pages, "limit") &&
      strcontains(local.classify_pages, "Other pages")
    )
    error_message = "The page-type pie must include the full eligible population, including Other, not a truncated top-N denominator."
  }

  assert {
    condition = alltrue([
      for widget in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets :
      widget.properties.region == var.region &&
      !strcontains(widget.properties.query, "dedup") &&
      !strcontains(widget.properties.query, "display @message") &&
      !can(regex("isblank\\([^)]*\\) = [01]", widget.properties.query)) &&
      !strcontains(widget.properties.query, "as @timestamp") &&
      !strcontains(widget.properties.query, "params")
      if widget.type == "log"
    ])
    error_message = "Queries must stay in the configured region, use composable aggregation and avoid displaying raw messages or params."
  }

  assert {
    condition = (
      strcontains(local.classify_pages, "page_controller = \"SearchReferencesController\", \"az\"") &&
      strcontains(local.classify_pages, "page_controller in [\"BrowseSectionsController\", \"SectionsController\", \"ChaptersController\", \"HeadingsController\", \"SubheadingsController\"], \"browse\"") &&
      strcontains(local.classify_pages, "activity = \"az\", \"A-Z index\"") &&
      strcontains(local.classify_pages, "activity = \"browse\", \"Browse tariff\"") &&
      alltrue([for query in [local.queries.pages, local.queries.volume, local.queries.behaviour] : strcontains(query, local.classify_pages)]) &&
      strcontains(local.queries.behaviour, "sum(if(activity = \"az\", 1, 0)) as az_visits") &&
      strcontains(local.queries.behaviour, "round(100 * sum(az_visits) / sum(visits), 2) as `A-Z (%)`") &&
      strcontains(local.queries.behaviour, "round(100 * sum(browse_visits) / sum(visits), 2) as `Browse (%)`")
    )
    error_message = "A-Z lookup and tariff hierarchy browsing must be separate activities across charts and frequency shares, using the same request denominator."
  }

  assert {
    condition = (
      local.page_names["BrowseSectionsController#index"].name == "Browse the tariff" &&
      local.page_names["SearchReferencesController#show"].name == "A-Z of Classified Goods" &&
      local.page_names["SearchController#quota_search"].name == "Search for quotas" &&
      local.page_names["SearchController#chemical_search"].name == "Search by Chemical" &&
      local.page_names["CommoditiesController#origin"].name == "Rules of origin (commodity tab)"
    )
    error_message = "UI mapping must distinguish browsing, specialist searches and origin tabs from commodity search/details."
  }

  assert {
    condition = alltrue([
      for mapping in values(local.page_names) :
      fileexists("${path.module}/../../../${mapping.source}") &&
      !strcontains(mapping.name, "Controller") && !strcontains(mapping.name, "#")
    ])
    error_message = "Every explicit page name needs an existing UI/source anchor and must not display controller/action identifiers."
  }

  assert {
    condition = (
      strcontains(local.page_requests, "earliest(request.action) as page_action") &&
      strcontains(local.page_requests, "earliest(request.method) as page_method") &&
      strcontains(local.name_pages, "(form submission)") &&
      strcontains(local.name_pages, "(redirect)") &&
      strcontains(local.queries.popular_pages, local.name_pages) &&
      strcontains(local.queries.first_last, local.name_pages) &&
      !strcontains(local.queries.popular_pages, "by page_path")
    )
    error_message = "Ranked and first/last tables must share the action-aware UI labels and preserve submission/redirect distinctions."
  }

  assert {
    condition = (
      strcontains(local.queries.first_last, "concat(requested_at, \"|\", page_label)") &&
      strcontains(local.queries.first_last, "sortsFirst(observation) as first_observation") &&
      strcontains(local.queries.first_last, "sortsLast(observation) as last_observation") &&
      strcontains(local.queries.first_last, "parse first_observation") &&
      strcontains(local.queries.first_last, "parse last_observation")
    )
    error_message = "First/last reporting must preserve chronological order after request deduplication without implicit @timestamp access."
  }

  assert {
    condition = (
      length(local.enquiry_steps) == 9 &&
      regex(local.enquiry_step_pattern, "/enquiry_form/contact_details").enquiry_step == "contact_details" &&
      regex(local.enquiry_step_pattern, "/xi/enquiry_form/goods_details").enquiry_step == "goods_details" &&
      !can(regex(local.enquiry_step_pattern, "/enquiry_form/some-answer")) &&
      regex(local.enquiry_step_pattern, "/enquiry_form/query?query=private").enquiry_step == "query" &&
      regex(local.enquiry_step_pattern, "/uk/enquiry_form/goods_details?editing=true").enquiry_step == "goods_details" &&
      !can(regex(local.enquiry_step_pattern, "/enquiry_form/some-answer?editing=true")) &&
      alltrue([for step in keys(local.enquiry_steps) :
        fileexists("${path.module}/../../../app/views/product_experience/enquiry_form/_${step}.html.erb")
      ])
    )
    error_message = "Enquiry labels must match only the nine fixed route steps backed by UI partials, never answers or query strings."
  }

  assert {
    condition = (
      strcontains(local.name_pages, "page_action in [\"form\", \"submit\"]") &&
      strcontains(local.classify_pages, "activity = \"enquiry\", \"Enquiry form\"") &&
      local.page_names["ProductExperience::EnquiryFormController#submit_form"].name == "Submit enquiry" &&
      local.page_names["ProductExperience::EnquiryFormController#confirmation"].name == "Enquiry: Your request has been submitted"
    )
    error_message = "Enquiry activity, step submissions, final submission and confirmation must remain distinguishable."
  }

  assert {
    condition = (
      strcontains(local.queries.behaviour, "as `Requests/session`") &&
      strcontains(local.queries.behaviour, "as `Enquiries (%)`") &&
      strcontains(local.queries.popular_pages, "fields page_label as Page") &&
      strcontains(local.queries.first_last, "as `First page`") &&
      strcontains(local.classify_pages, "activity = \"commodity\", \"Commodities\"") &&
      strcontains(local.classify_pages, "activity = \"guidance\", \"Help & guidance\"")
    )
    error_message = "Displayed fields and activity legends must use readable product-facing names."
  }

  assert {
    condition = alltrue(flatten([
      for i, a in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets : [
        for j, b in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets :
        i == j || a.x + a.width <= b.x || b.x + b.width <= a.x || a.y + a.height <= b.y || b.y + b.height <= a.y
      ]
    ]))
    error_message = "Dashboard widgets must not overlap."
  }

  assert {
    condition = (
      strcontains(local.cohort_expression, "'Medium'") &&
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "Low: 1-${local.frequency_thresholds.low_max}") &&
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "Medium: ${local.frequency_thresholds.low_max + 1}-${local.frequency_thresholds.regular_max}") &&
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "High: ${local.frequency_thresholds.regular_max + 1}+")
    )
    error_message = "Displayed frequency groups must match the query labels and configured thresholds."
  }

  assert {
    condition = (
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "not people") &&
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "selected window") &&
      jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).start == "-PT24H"
    )
    error_message = "The dashboard must explain session/window semantics and default to a bounded window."
  }
}
