locals {
  # Short, stable UI names. Dynamic goods descriptions, search text and news
  # titles are deliberately omitted. Source anchors are checked by module tests.
  page_names = {
    "FindCommoditiesController#show"                              = { name = "Find commodity codes", source = "app/views/find_commodities/show_revised.html.erb" }
    "SectionsController#index"                                    = { name = "Find commodity codes", source = "app/controllers/sections_controller.rb" }
    "BrowseSectionsController#index"                              = { name = "Browse the tariff", source = "app/views/browse_sections/index.html.erb" }
    "SearchReferencesController#show"                             = { name = "A-Z of Classified Goods", source = "app/views/search_references/show.html.erb" }
    "SectionsController#show"                                     = { name = "Tariff section", source = "app/models/section.rb" }
    "ChaptersController#show"                                     = { name = "Tariff chapter", source = "app/models/chapter.rb" }
    "HeadingsController#show"                                     = { name = "Tariff heading", source = "app/models/heading.rb" }
    "SubheadingsController#show"                                  = { name = "Tariff subheading", source = "app/models/subheading.rb" }
    "CommoditiesController#show"                                  = { name = "Commodity code details", source = "config/locales/en.yml" }
    "CommoditiesController#origin"                                = { name = "Rules of origin (commodity tab)", source = "app/controllers/commodities_controller.rb" }
    "SearchController#search"                                     = { name = "Search for a commodity", source = "app/views/search/interactive_question.html.erb" }
    "SearchController#quota_search"                               = { name = "Search for quotas", source = "config/locales/en.yml" }
    "SearchController#chemical_search"                            = { name = "Search by Chemical", source = "config/locales/en.yml" }
    "AdditionalCodeSearchController#new"                          = { name = "Search for additional codes", source = "app/views/search/additional_codes/_form.html.erb" }
    "AdditionalCodeSearchController#create"                       = { name = "Search for additional codes", source = "app/views/search/additional_codes/_form.html.erb" }
    "CertificateSearchController#new"                             = { name = "Search for a certificate, licence or document", source = "app/views/search/certificate/_form.html.erb" }
    "CertificateSearchController#create"                          = { name = "Search for a certificate, licence or document", source = "app/views/search/certificate/_form.html.erb" }
    "FootnoteSearchController#new"                                = { name = "Search by Footnote", source = "app/views/search/footnotes/_form.html.erb" }
    "FootnoteSearchController#create"                             = { name = "Search by Footnote", source = "app/views/search/footnotes/_form.html.erb" }
    "ExchangeRatesController#index"                               = { name = "Check foreign currency exchange rates", source = "app/views/exchange_rates/index.html.erb" }
    "ExchangeRatesController#show"                                = { name = "Currency exchange rates for a period", source = "app/views/exchange_rates/show.html.erb" }
    "SimplifiedProceduralValuesController#index"                  = { name = "Simplified procedure value rates", source = "app/views/pages/tools.html.erb" }
    "PagesController#tools"                                       = { name = "Tariff tools", source = "app/views/pages/tools.html.erb" }
    "PagesController#help"                                        = { name = "Help on using the tariff", source = "app/views/pages/help.html.erb" }
    "PagesController#help_find_commodity"                         = { name = "Getting help from HMRC to find a commodity code", source = "app/views/pages/help_find_commodity.html.erb" }
    "PagesController#howto"                                       = { name = "Using the tariff: guidance", source = "app/views/pages/howto.html.erb" }
    "PagesController#privacy"                                     = { name = "Privacy notice", source = "app/views/pages/privacy.html.erb" }
    "PagesController#terms"                                       = { name = "Terms and conditions", source = "app/views/pages/terms.html.erb" }
    "PagesController#cn2021_cn2022"                               = { name = "2022 UK goods classification", source = "app/views/pages/cn2021_cn2022.html.erb" }
    "PagesController#changes_999l"                                = { name = "Document Code 999L", source = "app/views/pages/changes_999l.html.erb" }
    "PagesController#rules_of_origin_duty_drawback"               = { name = "Duty drawback", source = "app/views/pages/rules_of_origin_duty_drawback.html.erb" }
    "PagesController#rules_of_origin_proof_requirements"          = { name = "Requirements for proving origin", source = "app/views/pages/rules_of_origin_proof_requirements.html.erb" }
    "PagesController#rules_of_origin_proof_verification"          = { name = "Verification for proving origin", source = "app/views/pages/rules_of_origin_proof_verification.html.erb" }
    "Pages::GlossaryController#index"                             = { name = "Rules of origin glossary", source = "app/views/pages/glossary/index.html.erb" }
    "Pages::GlossaryController#show"                              = { name = "Rules of origin glossary term", source = "app/views/pages/glossary/show.html.erb" }
    "RulesOfOrigin::ProofsController#index"                       = { name = "Proofs of origin for all trade agreements", source = "app/views/rules_of_origin/proofs/index.html.erb" }
    "AiSearchInformationController#show"                          = { name = "AI-assisted search: service update", source = "app/views/ai_search_information/show.html.erb" }
    "LiveIssuesController#index"                                  = { name = "Live issues log", source = "config/locales/en.yml" }
    "GreenLanes::StartsController#new"                            = { name = "Check simplified processes eligibility", source = "app/views/green_lanes/starts/new.html.erb" }
    "ProductExperience::EnquiryFormController#show"               = { name = "Enquiry: What do you need help with?", source = "app/views/product_experience/enquiry_form/_category.html.erb" }
    "ProductExperience::EnquiryFormController#check_your_answers" = { name = "Enquiry: Check your answers", source = "app/views/product_experience/enquiry_form/check_your_answers.html.erb" }
    "ProductExperience::EnquiryFormController#submit_form"        = { name = "Submit enquiry", source = "app/controllers/product_experience/enquiry_form_controller.rb" }
    "ProductExperience::EnquiryFormController#confirmation"       = { name = "Enquiry: Your request has been submitted", source = "app/views/product_experience/enquiry_form/confirmation.html.erb" }
    "NewsItemsController#index"                                   = { name = "Trade tariff news bulletin", source = "app/views/news_items/index.html.erb" }
    "NewsItemsController#show"                                    = { name = "Trade tariff news article", source = "app/views/news_items/show.html.erb" }
    "FeedbackController#new"                                      = { name = "Give feedback on Online Trade Tariff", source = "app/views/feedback/new.html.erb" }
    "FeedbackController#create"                                   = { name = "Give feedback on Online Trade Tariff", source = "app/views/feedback/new.html.erb" }
    "FeedbackController#thanks"                                   = { name = "Feedback submitted", source = "app/views/feedback/thanks.html.erb" }
    "ImportExportDatesController#show"                            = { name = "When are you planning to trade the goods?", source = "config/locales/en.yml" }
    "ImportExportDatesController#update"                          = { name = "When are you planning to trade the goods?", source = "config/locales/en.yml" }
    "DutyCalculator::Steps::CustomsValueController#show"          = { name = "What is the customs value of this import?", source = "app/views/duty_calculator/steps/customs_value/show.html.erb" }
    "DutyCalculator::Steps::CustomsValueController#create"        = { name = "What is the customs value of this import?", source = "app/views/duty_calculator/steps/customs_value/show.html.erb" }
    "DutyCalculator::Steps::ConfirmationController#show"          = { name = "Import duty calculator: check your answers", source = "app/views/duty_calculator/steps/confirmation/show.html.erb" }
    "DutyCalculator::Steps::DutyController#show"                  = { name = "Import duty calculation", source = "app/views/duty_calculator/steps/duty/show.html.erb" }
  }

  # form/submit actions share a controller but have fixed, allowlisted paths.
  # These are step names only, never answers, contact details or query parameters.
  enquiry_steps = {
    category                  = "What do you need help with?"
    enquiry_type              = "What does your enquiry relate to?"
    goods_details             = "Tell us about your goods"
    commodity_code            = "Do you already have a possible commodity code?"
    duty_details              = "Tell us about your duty question"
    quota_details             = "Tell us about your quota question"
    postal_or_baggage_details = "Tell us about your postal or baggage question"
    query                     = "How can we help you?"
    contact_details           = "Contact details"
  }
  enquiry_step_pattern    = "^/(?:uk/|xi/)?enquiry_form/(?<enquiry_step>${join("|", keys(local.enquiry_steps))})(?:\\?.*)?$"
  enquiry_step_expression = "case(${join(", ", [for step, name in local.enquiry_steps : "enquiry_step = ${jsonencode(step)}, ${jsonencode("Enquiry: ${name}")}"])}, \"Enquiry form (unmapped step)\")"

  page_name_fallback = <<-QUERY
    case(page_controller like /^DutyCalculator::/, "Import duty calculator: other step",
      page_controller like /^RulesOfOrigin::/, "Rules of origin: guidance step",
      page_controller like /^GreenLanes::/, "Check simplified processes eligibility",
      page_controller = "ProductExperience::EnquiryFormController", "Enquiry form",
      "Other public page (unmapped)")
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
