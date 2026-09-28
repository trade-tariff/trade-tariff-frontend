locals {
  # Provisional visit-count bands, not expertise labels or percentile cut-offs.
  # Counts cover each session's activity inside the dashboard's selected window.
  frequency_thresholds = {
    low_max     = 2
    regular_max = 9
  }
  frequency_labels = {
    low    = "1. Low (1-${local.frequency_thresholds.low_max})"
    medium = "2. Medium (${local.frequency_thresholds.low_max + 1}-${local.frequency_thresholds.regular_max})"
    high   = "3. High (${local.frequency_thresholds.regular_max + 1}+)"
  }
  cohort_expression = "if(visits <= ${local.frequency_thresholds.low_max}, ${jsonencode(local.frequency_labels.low)}, if(visits <= ${local.frequency_thresholds.regular_max}, ${jsonencode(local.frequency_labels.medium)}, ${jsonencode(local.frequency_labels.high)}))"

  # awslogs uses ecs/<container name>/<task id>. Scope before examining fields
  # because the platform log group also contains backend and other service logs.
  page_requests = <<-QUERY
    SOURCE 'platform-logs-${var.environment}'
    | filter @logStream like /^ecs\/frontend\//
    | parse @message /(?<request_json>\{.*\})$/
    | fields jsonParse(request_json) as request
    | filter request.format = "html" and ispresent(request.controller) and ispresent(request.status)
    | filter request.controller not like /${local.catalogue.excluded_controller_pattern}/
    | filter isblank(request.user_agent) or tolower(request.user_agent) not like /${local.catalogue.bot_pattern}/
    | filter ispresent(request.request_id) and request.request_id != ""
    | fields bin(1h) as hourly_bin
    | stats earliest(hourly_bin) as request_hour, earliest(@timestamp) as requested_at, earliest(request.controller) as page_controller, earliest(request.action) as page_action, earliest(request.method) as page_method, earliest(request.path) as page_path, earliest(request.status) as response_status, earliest(request.browser_session_id) as session_id by request.request_id
    | fields concat(page_controller, "#", page_action) as page_key
  QUERY

  activity_clause = {
    for activity in local.catalogue.activities : activity.id => join(" or ", [
      for matcher in activity.matchers : (
        matcher.type == "page_key" ? (
          length(matcher.values) == 1 ? "page_key = ${jsonencode(matcher.values[0])}" :
          "page_key in [${join(", ", [for value in matcher.values : jsonencode(value)])}]"
          ) : matcher.type == "controller" ? (
          length(matcher.values) == 1 ? "page_controller = ${jsonencode(matcher.values[0])}" :
          "page_controller in [${join(", ", [for value in matcher.values : jsonencode(value)])}]"
        ) : length(matcher.values) == 1 ? "page_controller like /^${matcher.values[0]}/" :
        "page_controller like /^(${join("|", matcher.values)})/"
      )
    ]) if length(activity.matchers) > 0
  }
  classified_activities = [for activity in local.catalogue.activities : activity if activity.id != "other"]
  other_activity_label  = one([for activity in local.catalogue.activities : activity.label if activity.id == "other"])
  classify_pages        = <<-QUERY
    fields case(${join(", ", [for activity in local.classified_activities : "${local.activity_clause[activity.id]}, ${jsonencode(activity.id)}"])}, "other") as activity
    | fields case(${join(", ", [for activity in local.classified_activities : "activity = ${jsonencode(activity.id)}, \"${activity.label}\""])}, "${local.other_activity_label}") as page_type
  QUERY

  tariff_page_keys = local.catalogue.tariff_keys
  # case() requires a default result; the action filter makes it unreachable.
  tariff_requests = <<-QUERY
    ${local.page_requests}
    | filter page_key in ${jsonencode(local.tariff_page_keys)}
    | fields case(${join(", ", [for key in local.tariff_page_keys : "page_key = ${jsonencode(key)}, ${jsonencode(local.page_names[key].name)}"])}, "Other tariff page") as Page
  QUERY

  # Current Logs Insights supports up to ten stats commands per query.
  # Session reports need three: request deduplication, session totals, groups.
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax-Stats.html
  session_counts = <<-QUERY
    ${local.page_requests}
    | filter not isblank(session_id)
    | stats count(*) as visits by session_id
  QUERY

  # Request totals, coverage, tariff levels and status classes are container
  # metrics. These remaining queries need a selected-window session grouping
  # that a counter cannot answer.
  queries = {
    cohorts = <<-QUERY
      ${local.session_counts}
      | fields ${local.cohort_expression} as `Frequency group`
      | stats count(*) as Sessions by `Frequency group`
      | sort `Frequency group` asc
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
          sum(if(activity = "az", 1, 0)) as az_visits,
          sum(if(activity = "commodity", 1, 0)) as commodity_visits,
          sum(if(activity = "calculator", 1, 0)) as calculator_visits,
          sum(if(activity = "tools", 1, 0)) as tool_visits,
          sum(if(activity = "enquiry", 1, 0)) as enquiry_visits,
          sum(if(activity = "guidance", 1, 0)) as guidance_visits,
          sum(if(activity = "other", 1, 0)) as other_visits by session_id
      | fields ${local.cohort_expression} as `Frequency group`
      | stats count(*) as Sessions, sum(visits) as Requests, round(avg(visits), 2) as `Requests/session`,
          round(100 * sum(search_visits) / sum(visits), 2) as `Search %`,
          round(100 * sum(browse_visits) / sum(visits), 2) as `Browse %`,
          round(100 * sum(az_visits) / sum(visits), 2) as `A-Z %`,
          round(100 * sum(commodity_visits) / sum(visits), 2) as `Commodities %`,
          round(100 * sum(calculator_visits) / sum(visits), 2) as `Calculator %`,
          round(100 * sum(tool_visits) / sum(visits), 2) as `Tools %`,
          round(100 * sum(enquiry_visits) / sum(visits), 2) as `Enquiries %`,
          round(100 * sum(guidance_visits) / sum(visits), 2) as `Guidance %`,
          round(100 * sum(other_visits) / sum(visits), 2) as `Other %` by `Frequency group`
      | sort `Frequency group` asc
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
