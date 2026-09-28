locals {
  # Shared with lib/page_visit_metrics.rb. Do not keep a second copy of these names.
  catalogue     = jsondecode(file("${path.module}/../../../config/page_visit_catalogue.json"))
  page_names    = local.catalogue.page_names
  enquiry_steps = local.catalogue.enquiry_steps
  fallbacks     = local.catalogue.fallbacks

  enquiry_step_pattern    = "^/(?:uk/|xi/)?enquiry_form/(?<enquiry_step>${join("|", keys(local.enquiry_steps))})(?:\\?.*)?$"
  enquiry_step_expression = "case(${join(", ", [for step, name in local.enquiry_steps : "enquiry_step = ${jsonencode(step)}, ${jsonencode("Enquiry: ${name}")}"])}, ${jsonencode(local.fallbacks.enquiry_unmapped_step)})"

  page_name_fallback = <<-QUERY
    case(page_controller like /^DutyCalculator::/, ${jsonencode(local.fallbacks.duty_calculator)},
      page_controller like /^RulesOfOrigin::/, ${jsonencode(local.fallbacks.rules_of_origin)},
      page_controller like /^GreenLanes::/, ${jsonencode(local.fallbacks.green_lanes)},
      page_controller = "ProductExperience::EnquiryFormController", ${jsonencode(local.fallbacks.enquiry)},
      ${jsonencode(local.fallbacks.unmapped)})
  QUERY

  # Each Logs Insights case() supports at most ten branches. Nest bounded chunks
  # so adding a mapping cannot silently exceed that limit.
  page_name_cases = [for keys in chunklist(sort(keys(local.page_names)), 10) :
    join(", ", [for key in keys : "page_key = ${jsonencode(key)}, ${jsonencode(local.page_names[key].name)}"])
  ]
  page_name_expression = join("", concat(
    [for branches in local.page_name_cases : "case(${branches}, "],
    [trimspace(local.page_name_fallback)],
    [for branches in local.page_name_cases : ")"]
  ))

  name_pages = <<-QUERY
    parse page_path /${replace(local.enquiry_step_pattern, "/", "\\/")}/
    | fields if(page_controller = "ProductExperience::EnquiryFormController" and page_action in ["form", "submit"],
        ${local.enquiry_step_expression}, ${local.page_name_expression}) as page_name
    | fields concat(page_name,
        if(page_method in ["GET", "HEAD"], "", " (form submission)"),
        if(response_status >= 300 and response_status < 400, " (redirect)", "")) as page_label
  QUERY
}
