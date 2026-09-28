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
      strcontains(widget.properties.query, "by request.request_id") &&
      strcontains(widget.properties.query, local.catalogue.excluded_controller_pattern) &&
      strcontains(widget.properties.query, local.catalogue.bot_pattern)
      if widget.type == "log"
    ])
    error_message = "Session reports must select the same frontend HTML requests as the container metrics and collapse duplicate request records."
  }

  assert {
    condition     = length([for widget in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets : widget if widget.type == "log"]) == 4
    error_message = "Only the four selected-window session reports should scan logs."
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
      strcontains(local.cohort_expression, local.frequency_labels.low) &&
      strcontains(local.cohort_expression, local.frequency_labels.medium) &&
      strcontains(local.cohort_expression, local.frequency_labels.high) &&
      local.frequency_thresholds.low_max > 0 &&
      local.frequency_thresholds.regular_max > local.frequency_thresholds.low_max
    )
    error_message = "Cohort queries must use ordered, inclusive thresholds and the same labels as the dashboard text."
  }

  assert {
    condition = (
      strcontains(local.queries.cohorts, "filter not isblank(session_id)") &&
      strcontains(local.queries.cohorts, "by session_id") &&
      strcontains(local.queries.cohorts, "count(*) as Sessions by `Frequency group`") &&
      strcontains(local.queries.behaviour, "filter not isblank(session_id)") &&
      strcontains(local.queries.first_last, "filter not isblank(session_id)") &&
      !contains(keys(local.queries), "coverage") &&
      !contains(keys(local.queries), "pages") &&
      !contains(keys(local.queries), "volume") &&
      !contains(keys(local.queries), "responses") &&
      !contains(keys(local.queries), "popular_pages")
    )
    error_message = "Session reports must exclude missing identifiers, and request totals must not remain as log scans."
  }

  assert {
    condition = (
      strcontains(local.classify_pages, "page_controller = \"SearchReferencesController\", \"az\"") &&
      strcontains(local.classify_pages, "page_controller in [\"BrowseSectionsController\", \"SectionsController\", \"ChaptersController\", \"HeadingsController\", \"SubheadingsController\"], \"browse\"") &&
      strcontains(local.classify_pages, "activity = \"az\", \"A-Z index\"") &&
      strcontains(local.classify_pages, "activity = \"browse\", \"Browse tariff\"") &&
      strcontains(local.classify_pages, "activity = \"commodity\", \"Commodities\"") &&
      strcontains(local.classify_pages, "activity = \"guidance\", \"Help & guidance\"") &&
      strcontains(local.classify_pages, "activity = \"enquiry\", \"Enquiry form\"") &&
      strcontains(local.queries.behaviour, trimspace(local.classify_pages)) &&
      strcontains(local.queries.behaviour, "sum(if(activity = \"az\", 1, 0)) as az_visits") &&
      strcontains(local.queries.behaviour, "as `A-Z %`") &&
      strcontains(local.queries.behaviour, "as `Browse %`") &&
      strcontains(local.queries.behaviour, "as `Requests/session`") &&
      strcontains(local.queries.behaviour, "as `Enquiries %`")
    )
    error_message = "A-Z lookup and tariff browsing must stay separate activities, using the catalogue labels and the same session-request denominator."
  }

  assert {
    condition = (
      toset(local.tariff_page_keys) == toset(local.catalogue.tariff_keys) &&
      toset(local.tariff_page_keys) == toset([
        "BrowseSectionsController#index", "SectionsController#show", "ChaptersController#show",
        "HeadingsController#show", "SubheadingsController#show", "CommoditiesController#show",
      ]) &&
      alltrue([for key in local.tariff_page_keys : contains(keys(local.page_names), key)]) &&
      length([for widget in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets : widget if try(widget.properties.title, "") == "Tariff page requests (selected range)" && widget.type == "metric" && widget.properties.view == "bar"]) == 1
    )
    error_message = "Tariff metric charts must use the six catalogue page types, not a log scan or a top-N cutoff."
  }

  assert {
    condition = (
      local.page_names["BrowseSectionsController#index"].name == "Browse the tariff" &&
      local.page_names["SearchReferencesController#show"].name == "A-Z of Classified Goods" &&
      local.page_names["SearchController#quota_search"].name == "Search for quotas" &&
      local.page_names["SearchController#chemical_search"].name == "Search by Chemical" &&
      local.page_names["CommoditiesController#origin"].name == "Rules of origin (commodity tab)" &&
      local.catalogue.namespace == "TradeTariff/PageVisits" &&
      local.catalogue.service == "frontend" &&
      local.catalogue.metric == "PageRequests"
    )
    error_message = "UI mapping and metric identity must stay on the shared catalogue."
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
      alltrue([
        for widget in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets :
        widget.properties.region == var.region &&
        !strcontains(try(widget.properties.query, ""), "dedup") &&
        !strcontains(try(widget.properties.query, ""), "display @message") &&
        !strcontains(try(widget.properties.query, ""), "params")
        if widget.type == "log" || widget.type == "metric"
      ]) &&
      alltrue([
        for widget in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets :
        !strcontains(jsonencode(widget.properties), "browser_session_id") &&
        !strcontains(jsonencode(widget.properties), "request_id")
        if widget.type == "metric"
      ])
    )
    error_message = "Widgets must stay in the configured region. Metric widgets must not carry session or request identifiers."
  }

  assert {
    condition = (
      alltrue([
        for activity in local.catalogue.activities :
        length([for widget in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets : widget if widget.type == "metric" && strcontains(jsonencode(widget.properties), "\"id\":\"${activity.id}\"")]) >= 1
      ]) &&
      alltrue([
        for status in local.catalogue.statuses :
        length([for widget in jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets : widget if widget.type == "metric" && strcontains(jsonencode(widget.properties), "\"id\":\"${status.id}\"")]) >= 1
      ]) &&
      strcontains(jsonencode(aws_cloudwatch_dashboard.page_visits.dashboard_body), local.catalogue.coverage.present) &&
      strcontains(jsonencode(aws_cloudwatch_dashboard.page_visits.dashboard_body), local.catalogue.coverage.missing) &&
      strcontains(jsonencode(aws_cloudwatch_dashboard.page_visits.dashboard_body), local.catalogue.mapping.unmapped) &&
      strcontains(jsonencode(aws_cloudwatch_dashboard.page_visits.dashboard_body), "Environment,Service,Page")
    )
    error_message = "Every catalogue request counter must appear on the dashboard with the same dimension values."
  }

  assert {
    condition = (
      strcontains(local.page_requests, "earliest(request.action) as page_action") &&
      strcontains(local.page_requests, "earliest(request.method) as page_method") &&
      strcontains(local.name_pages, "(form submission)") &&
      strcontains(local.name_pages, "(redirect)") &&
      strcontains(local.queries.first_last, local.name_pages) &&
      !strcontains(local.queries.first_last, "by page_path")
    )
    error_message = "First and last reports must keep the action-aware UI labels and submission/redirect distinctions."
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
      local.page_names["ProductExperience::EnquiryFormController#submit_form"].name == "Submit enquiry" &&
      local.page_names["ProductExperience::EnquiryFormController#confirmation"].name == "Enquiry: Your request has been submitted"
    )
    error_message = "Enquiry step submissions, final submission and confirmation must remain distinguishable."
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
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "Low: 1-${local.frequency_thresholds.low_max}") &&
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "Medium: ${local.frequency_thresholds.low_max + 1}-${local.frequency_thresholds.regular_max}") &&
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "High: ${local.frequency_thresholds.regular_max + 1}+") &&
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "not people") &&
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "selected window") &&
      strcontains(jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).widgets[0].properties.markdown, "container metrics") &&
      jsondecode(aws_cloudwatch_dashboard.page_visits.dashboard_body).start == "-PT24H"
    )
    error_message = "The dashboard must explain session/window semantics, metric collection and the bounded default window."
  }
}
