locals {
  # Provisional visit-count bands, not expertise labels or percentile cut-offs.
  # Counts cover each session's activity inside the dashboard's selected window.
  frequency_thresholds = {
    low_max     = 2
    regular_max = 9
  }
  cohort_expression = "if(visits <= ${local.frequency_thresholds.low_max}, 'Low', if(visits <= ${local.frequency_thresholds.regular_max}, 'Medium', 'High'))"

  # awslogs uses ecs/<container name>/<task id>. Scope before examining fields
  # because the platform log group also contains backend and other service logs.
  page_requests = <<-QUERY
    SOURCE 'platform-logs-${var.environment}'
    | filter @logStream like /^ecs\/frontend\//
    | parse @message /(?<request_json>\{.*\})$/
    | fields jsonParse(request_json) as request
    | filter request.format = "html" and ispresent(request.controller) and ispresent(request.status)
    | filter request.controller not like /^(Myott::|BasicSessionsController|HealthcheckController|Cookies::)/
    | filter isblank(request.user_agent) or tolower(request.user_agent) not like /bot|crawler|spider|headless|synthetic|healthcheck/
    | filter ispresent(request.request_id) and request.request_id != ""
    | fields bin(1h) as hourly_bin
    | stats earliest(hourly_bin) as request_hour, earliest(@timestamp) as requested_at, earliest(request.controller) as page_controller, earliest(request.action) as page_action, earliest(request.method) as page_method, earliest(request.path) as page_path, earliest(request.status) as response_status, earliest(request.browser_session_id) as session_id by request.request_id
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
    | fields case(activity = "search", "Search",
      activity = "browse", "Browse / A-Z",
      activity = "commodity", "Commodities",
      activity = "calculator", "Duty calculator",
      activity = "tools", "Tariff tools",
      activity = "enquiry", "Enquiry form",
      activity = "guidance", "Help & guidance",
      "Other pages") as page_type
  QUERY

  # Current Logs Insights supports up to ten stats commands per query.
  # Session reports need three: request deduplication, session totals, groups.
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax-Stats.html
  session_counts = <<-QUERY
    ${local.page_requests}
    | filter not isblank(session_id)
    | stats count(*) as visits by session_id
  QUERY

  queries = {
    cohorts = <<-QUERY
      ${local.session_counts}
      | fields ${local.cohort_expression} as `Frequency group`
      | stats count(*) as Sessions by `Frequency group`
    QUERY

    pages = <<-QUERY
      ${local.page_requests}
      | ${local.classify_pages}
      | fields page_type as Activity
      | stats count(*) as Requests by Activity
    QUERY

    coverage = <<-QUERY
      ${local.page_requests}
      | fields if(isblank(session_id), "Missing ID", "Correlated") as Coverage
      | stats count(*) as Requests by Coverage
    QUERY

    volume = <<-QUERY
      ${local.page_requests}
      | ${local.classify_pages}
      | fields request_hour as Hour, page_type as Activity
      | stats count(*) as Requests by Hour, Activity
    QUERY

    distribution = <<-QUERY
      ${local.session_counts}
      | fields if(visits > 20, 21, visits) as Visits
      | stats count(*) as Sessions by Visits
      | sort Visits asc
    QUERY

    behaviour = <<-QUERY
      ${local.page_requests}
      | filter not isblank(session_id)
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
      | fields ${local.cohort_expression} as `Frequency group`
      | stats count(*) as Sessions, sum(visits) as Requests, round(avg(visits), 2) as `Requests/session`,
          round(100 * sum(search_visits) / sum(visits), 2) as `Search (%)`,
          round(100 * sum(browse_visits) / sum(visits), 2) as `Browse (%)`,
          round(100 * sum(commodity_visits) / sum(visits), 2) as `Commodities (%)`,
          round(100 * sum(calculator_visits) / sum(visits), 2) as `Calculator (%)`,
          round(100 * sum(tool_visits) / sum(visits), 2) as `Tools (%)`,
          round(100 * sum(enquiry_visits) / sum(visits), 2) as `Enquiries (%)`,
          round(100 * sum(guidance_visits) / sum(visits), 2) as `Guidance (%)`,
          round(100 * sum(other_visits) / sum(visits), 2) as `Other (%)` by `Frequency group`
    QUERY

    responses = <<-QUERY
      ${local.page_requests}
      | fields case(response_status >= 500, "5xx errors", response_status >= 400, "4xx errors", response_status >= 300, "3xx redirects", "2xx success") as response_class
      | fields request_hour as Hour, response_class as Response
      | stats count(*) as Requests by Hour, Response
    QUERY

    popular_pages = <<-QUERY
      ${local.page_requests}
      | ${local.name_pages}
      | fields page_label as Page
      | stats count(*) as Requests by Page
      | sort Requests desc
      | limit 20
    QUERY

    first_last = <<-QUERY
      ${local.page_requests}
      | filter not isblank(session_id)
      | ${local.name_pages}
      | fields concat(requested_at, "|", page_label) as observation
      | stats sortsFirst(observation) as first_observation, sortsLast(observation) as last_observation by session_id
      | parse first_observation /^[0-9]+\|(?<first_page>.*)$/
      | parse last_observation /^[0-9]+\|(?<last_page>.*)$/
      | fields first_page as `First page`, last_page as `Last page`
      | stats count(*) as Sessions by `First page`, `Last page`
      | sort Sessions desc
      | limit 20
    QUERY
  }
}
