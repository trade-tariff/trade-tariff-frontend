locals {
  # Provisional visit-count bands, not expertise labels or percentile cut-offs.
  # Counts cover each session's activity inside the dashboard's selected window.
  frequency_thresholds = {
    low_max     = 2
    regular_max = 9
  }
  cohort_expression = "if(visits <= ${local.frequency_thresholds.low_max}, 'Low frequency', if(visits <= ${local.frequency_thresholds.regular_max}, 'Regular', 'High frequency'))"

  # awslogs uses ecs/<container name>/<task id>. Scope before examining fields
  # because the platform log group also contains backend and other service logs.
  page_requests = <<-QUERY
    SOURCE 'platform-logs-${var.environment}'
    | filter @logStream like /^ecs\/frontend\//
    | filter format = "html" and ispresent(controller) and ispresent(status)
    | filter controller not like /^(Myott::|BasicSessionsController|HealthcheckController|Cookies::)/
    | filter isblank(user_agent) = 1 or tolower(user_agent) not like /bot|crawler|spider|headless|synthetic|healthcheck/
    | filter ispresent(request_id) and request_id != ""
    | stats earliest(@timestamp) as requested_at, earliest(controller) as page_controller, earliest(action) as page_action, earliest(method) as page_method, earliest(path) as page_path, earliest(status) as response_status, earliest(browser_session_id) as session_id by request_id
    | fields concat(page_controller, "#", page_action) as page_key
  QUERY

  # The pie uses eight readable activity groups; ranked and first/last tables
  # use the detailed UI names in page_names.tf. Controller alone is insufficient:
  # Search also serves quota/chemical tools, and Commodities serves origin tabs.
  classify_pages = <<-QUERY
    fields case(
      page_key in ["FindCommoditiesController#show", "SectionsController#index", "SearchController#search"], "search",
      page_controller in ["BrowseSectionsController", "SearchReferencesController", "SectionsController", "ChaptersController", "HeadingsController", "SubheadingsController"], "browse",
      page_key = "CommoditiesController#show", "commodity",
      page_controller like /^DutyCalculator::/, "calculator",
      page_key in ["SearchController#quota_search", "SearchController#chemical_search", "PagesController#tools"] or page_controller in ["AdditionalCodeSearchController", "CertificateSearchController", "FootnoteSearchController", "ExchangeRatesController", "SimplifiedProceduralValuesController"] or page_controller like /^MeursingLookup::/, "tools",
      page_controller = "ProductExperience::EnquiryFormController", "enquiry",
      page_key = "CommoditiesController#origin" or page_controller like /^(RulesOfOrigin::|GreenLanes::|Pages::|ProductExperience::)/ or page_controller in ["PagesController", "NewsItemsController", "FeedbackController", "AiSearchInformationController", "LiveIssuesController"], "guidance",
      "other"
    ) as activity
    | fields case(activity = "search", "Find and search for commodity codes",
      activity = "browse", "Browse the tariff and A-Z",
      activity = "commodity", "Commodity code details",
      activity = "calculator", "Import duty calculator",
      activity = "tools", "Tariff tools",
      activity = "enquiry", "Enquiry form",
      activity = "guidance", "Help, news and rules of origin",
      "Other public pages") as page_type
  QUERY

  session_counts = <<-QUERY
    ${local.page_requests}
    | filter isblank(session_id) = 0
    | stats count(*) as visits by session_id
  QUERY

  queries = {
    cohorts = <<-QUERY
      ${local.session_counts}
      | fields ${local.cohort_expression} as frequency_group
      | stats count(*) as sessions by frequency_group
    QUERY

    pages = <<-QUERY
      ${local.page_requests}
      | ${local.classify_pages}
      | stats count(*) as page_requests by page_type
    QUERY

    coverage = <<-QUERY
      ${local.page_requests}
      | fields if(isblank(session_id) = 1, "Missing session ID", "Correlated") as coverage
      | stats count(*) as page_requests by coverage
    QUERY

    volume = <<-QUERY
      ${local.page_requests}
      | ${local.classify_pages}
      | stats count(*) as page_requests by datefloor(requested_at, 1h), page_type
    QUERY

    distribution = <<-QUERY
      ${local.session_counts}
      | fields if(visits > 20, 21, visits) as visits_in_window
      | stats count(*) as sessions by visits_in_window
      | sort visits_in_window asc
    QUERY

    behaviour = <<-QUERY
      ${local.page_requests}
      | filter isblank(session_id) = 0
      | ${local.classify_pages}
      | stats count(*) as visits,
          sum(if(activity = "search", 1, 0)) as search_visits,
          sum(if(activity = "browse", 1, 0)) as browse_visits,
          sum(if(activity = "commodity", 1, 0)) as commodity_visits,
          sum(if(activity = "calculator", 1, 0)) as calculator_visits,
          sum(if(activity = "tools", 1, 0)) as tool_visits,
          sum(if(activity = "enquiry", 1, 0)) as enquiry_visits,
          sum(if(activity = "guidance", 1, 0)) as guidance_visits,
          sum(if(activity = "other", 1, 0)) as other_visits by session_id
      | fields ${local.cohort_expression} as frequency_group
      | stats count(*) as sessions, sum(visits) as page_requests, avg(visits) as requests_per_session,
          100 * sum(search_visits) / sum(visits) as search_pct,
          100 * sum(browse_visits) / sum(visits) as browse_pct,
          100 * sum(commodity_visits) / sum(visits) as commodity_pct,
          100 * sum(calculator_visits) / sum(visits) as calculator_pct,
          100 * sum(tool_visits) / sum(visits) as tools_pct,
          100 * sum(enquiry_visits) / sum(visits) as enquiry_pct,
          100 * sum(guidance_visits) / sum(visits) as guidance_pct,
          100 * sum(other_visits) / sum(visits) as other_pct by frequency_group
    QUERY

    responses = <<-QUERY
      ${local.page_requests}
      | fields case(response_status >= 500, "5xx errors", response_status >= 400, "4xx errors", response_status >= 300, "3xx redirects", "2xx success") as response_class
      | stats count(*) as page_requests by datefloor(requested_at, 1h), response_class
    QUERY

    popular_pages = <<-QUERY
      ${local.page_requests}
      | ${local.name_pages}
      | stats count(*) as page_requests by page_label
      | sort page_requests desc
      | limit 20
    QUERY

    first_last = <<-QUERY
      ${local.page_requests}
      | filter isblank(session_id) = 0
      | ${local.name_pages}
      | fields requested_at as @timestamp
      | stats earliest(page_label) as first_page, latest(page_label) as last_page by session_id
      | stats count(*) as sessions by first_page, last_page
      | sort sessions desc
      | limit 20
    QUERY
  }
}
