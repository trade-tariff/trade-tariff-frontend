# Frontend Page Visits dashboard

Product reporting for [AI-1313](https://transformuk.atlassian.net/browse/AI-1313),
using the controller-log correlation added by
[AI-1091](https://transformuk.atlassian.net/browse/AI-1091).

## Read the dashboard

`Frontend-Page-Visits-<environment>` defaults to the last 24 hours. Start with
session-ID coverage, then compare the two main pies:

- **Browser sessions by request frequency:** number of distinct observed
  browser-session IDs in each group. These are reporting identities, not verified
  people. Low, Medium and High describe request counts in the selected period,
  not how regularly someone returns to the service.
- **Share of requests by activity:** share of eligible requests by activity group,
  including Other. The separate top-20 page table shows UI names mapped from
  controller/action pairs, distinguishing form submissions and redirects.

The two pies have different denominators: sessions versus requests. They must not
be compared as if they represented the same population.

Other views show hourly traffic by page type, visits-per-session distribution,
activity shares by frequency group, responses by status class, and the
first/last observed named pages for each session. The distribution caps its final
bucket at 21: that bucket includes every session with 21 or more visits.

The first/last table is not an entry/exit funnel or bounce rate. It describes only
observations within the selected window, including single-request sessions.
The most popular named pages and first/last pairs are limited to 20 rows; the
pies do not truncate their populations. Individual commodity codes and product
descriptions are not displayed.

## UI names, not controller names

`terraform/modules/frontend_page_visits_dashboard/page_names.tf` is the shared
mapping used by the ranked-page and first/last-page tables. Each explicit name
includes a source anchor to a frontend heading, page title, navigation label or
controller render/redirect behaviour. Dynamic search text, goods descriptions,
news titles and other user-specific content are omitted.

Representative mappings (names may be shortened for chart readability):

| Controller/action in the log | Widget name | UI/source |
| --- | --- | --- |
| `FindCommoditiesController#show` | Find commodity codes | `find_commodities/show_revised`, legacy `show` says Look up |
| `SectionsController#index` | Find commodity codes (redirect) | Redirects to `find_commodity`; not a section-list display |
| `BrowseSectionsController#index` | Browse the tariff | `browse_sections/index` heading |
| `SearchReferencesController#show` | A-Z of Classified Goods | `search_references/show` heading |
| `SectionsController#show` | Tariff section | `Section#page_heading` |
| `ChaptersController#show` | Tariff chapter | `Chapter#page_heading` |
| `HeadingsController#show` | Tariff heading | `Heading#page_heading` |
| `SubheadingsController#show` | Tariff subheading | `Subheading#page_heading` |
| `CommoditiesController#show` | Commodity code details | Commodity page title |
| `CommoditiesController#origin` | Rules of origin (commodity tab) | Renders the rules-of-origin tab, sometimes via XHR |
| `SearchController#search` | Search for a commodity | General name: action renders multiple search screens |
| `SearchController#quota_search` | Search for quotas | Quota form heading |
| `SearchController#chemical_search` | Search by Chemical | Chemical form heading |
| `AdditionalCodeSearchController#new/create` | Search for additional codes | Additional-code form heading |
| `CertificateSearchController#new/create` | Search for a certificate, licence or document | Certificate form heading |
| `FootnoteSearchController#new/create` | Search by Footnote | Footnote form heading |
| `PagesController#tools` | Tariff tools | Tools page heading |
| `ExchangeRatesController#index/show` | Check foreign currency exchange rates / Currency exchange rates for a period | Exchange-rate headings |
| `NewsItemsController#index/show` | Trade tariff news bulletin / Trade tariff news article | News headings; no dynamic article title |
| `FeedbackController#new/create/thanks` | Give feedback on Online Trade Tariff / Feedback submitted | Form and confirmation headings |
| Duty calculator customs-value / confirmation / duty actions | Customs-value question / Check your answers / Import duty calculation | Calculator step headings |

POST/PATCH/other non-GET/HEAD requests add **(form submission)**. A 3xx status adds
**(redirect)**, including on form submissions. These annotations describe the
request, not proof of successful validation or a destination page display.

The pie, hourly activity chart and behaviour table use nine activity labels:
Search, Browse tariff, A-Z index, Commodities, Duty calculator, Tariff tools, Enquiry form,
Help & guidance, and Other pages. Enquiry form remains its own activity rather
than being folded into general help. Table columns use readable names and
percentages are rounded to two decimal places; rounded shares may not sum to
exactly 100%. Browse tariff covers navigating sections, chapters, headings and
subheadings, including the browse landing page. A-Z index covers alphabetical
classified-goods lookup through `SearchReferencesController`; it is distinct from
both tariff browsing and commodity search. The section-index redirect to Find
commodity codes remains Search. Splitting A-Z from browsing does not change
request totals, session totals or frequency thresholds. Quota, chemical and code lookups count as
Tariff tools, not commodity search. Commodity origin-tab requests count as
Help, news and rules of origin, not commodity details.

Controller/action alone cannot reliably identify a guided question, results,
no-results or blocking screen: all can use `SearchController#search`. Likewise,
rules-of-origin steps and some calculator decisions can share an action. Use
explicit generic family labels for those cases; do not infer a screen from form
values or include raw query text. Unmapped requests are shown as **Other public
page (unmapped)** so coverage gaps remain visible.

### Enquiry form steps

The enquiry form's `form` and `submit` actions are disambiguated using only the
fixed `/enquiry_form/<step>` path segment (also accepting UK/XI prefixes). The
allowlist comes from `local.enquiry_steps`, with a matching frontend partial for
each entry. No submitted content, contact values, reference numbers or query
strings are used. Labels carry an `Enquiry:` prefix for context.

| Step segment | UI label |
| --- | --- |
| `category` | What do you need help with? |
| `enquiry_type` | What does your enquiry relate to? |
| `goods_details` | Tell us about your goods |
| `commodity_code` | Do you already have a possible commodity code? |
| `duty_details` | Tell us about your duty question |
| `quota_details` | Tell us about your quota question |
| `postal_or_baggage_details` | Tell us about your postal or baggage question |
| `query` | How can we help you? |
| `contact_details` | Contact details |

The opening action maps to the category question. Check-your-answers, the final
**Submit enquiry** request and **Your request has been submitted** confirmation
have separate labels. Form-submission and redirect annotations still apply. A
submission request is not itself proof of success; the confirmation can also
redirect if its session context is unavailable. Unknown step paths retain a
generic unmapped-step label rather than displaying arbitrary path content.

## Frequency definition

Edit `local.frequency_thresholds` in
`terraform/modules/frontend_page_visits_dashboard/queries.tf`:

| Group | Visits within the selected window |
| --- | --- |
| Low frequency | 1-2 |
| Medium frequency | 3-9 |
| High frequency | 10+ |

These are provisional product defaults, not observed 20th/80th percentiles or
expertise classifications. Both cohort reports and dashboard explanatory text
use the same local thresholds. Equal counts always receive the same group.

A browser-session ID is the accepted reporting identity. Session resets lose
continuity; we do not add login tracking or link persistent browser identities.
Changing the dashboard time range can change a session's group. A missing ID is
not a low-frequency session: those requests are counted in the coverage pie but
excluded from cohort and first/last reports.

This delivers retrospective dashboard groups. It does not assign a prior-only
group to a search journey at journey start, establish monthly history, enforce
20/60/20 groups, or compare search outcomes. Those remaining AI-1313 capabilities
must not be inferred from this dashboard.

## Page-request definition

The source is `platform-logs-<environment>`, restricted to streams starting
`ecs/frontend/`, matching the ECS awslogs stream convention. Explicitly extract
and parse the JSON object because Rails can prefix it with its logger timestamp
and request tag. Select controller records with `format = "html"` and a status;
never display the raw message or submitted parameters.

- Count each HTTP request ID once, collapsing duplicate records. Separate
  requests to the same page still count separately.
- Include public HTML GETs, form submissions, refreshes, redirects and errors.
  These are server-observed page requests, not proof of a visible page view.
- Exclude authentication/subscription controllers, basic-auth pages, health
  checks and cookie-management controllers. Non-HTML background events and
  assets are excluded, including `guided_search.journey` telemetry.
- Exclude user agents matching the documented bot/crawler/spider/headless/
  synthetic/healthcheck expression in the query. This is a heuristic, not proof
  of human traffic. Requests without user agents remain included. Manual test
  traffic may remain; prefer a controlled staging window for validation.
- Records without HTTP request IDs are excluded because they cannot be reliably
  collapsed. Inspect raw-record coverage during staging validation.
- Chart UI names and activity groups rather than raw paths, controller names,
  params or query strings. No raw messages or session IDs are displayed.
  HTML fragment/tab requests may remain included: format alone does not prove
  full-page navigation. The origin-tab mapping makes that distinction explicit.

Page and session totals are grouped from request records rather than summing
per-hour distinct estimates. Hourly charts preserve the earliest request's
`bin(1h)` bucket through duplicate collapse. Logs Insights does not allow
restoring its implicit `@timestamp` after aggregation. First/last ordering uses
the deduplicated timestamp's 13-digit epoch-millisecond string followed by the
page label, then strips the timestamp from the output. Tied timestamps use
alphabetical label order, not a claim about which page was displayed first.

## Coverage, cost and access

Historical session coverage begins when the AI-1091 logging change is deployed
to the selected environment, not at its merge date. A full-day window can mix
older uncorrelated requests with newer correlated requests. Check a recent
post-deployment window before diagnosing current collection failures; retain
missing IDs in historical coverage rather than hiding them.

Development validation on 10 September 2026 found a Standard-class log group
with seven-day retention. In the sampled hour, all 52 eligible requests in the
11:05 UTC bucket lacked IDs, while all 108 observed requests from 11:15 UTC
onward had IDs. This is bounded development evidence, not a guarantee for other
environments or future traffic. Empty charts must not be interpreted as zero
visitors or complete historical coverage.

Each dashboard refresh runs nine Logs Insights queries over a shared platform
log group. Prefer manual refresh and bounded windows. Measure bytes scanned and
query duration before adopting longer windows or frequent refresh. A result
limit is not a scan-cost budget. Terraform does not set the viewer's refresh
interval here.

The module creates a dashboard only. It adds no collection, metric dimensions,
IAM grants, identity linkage, retention changes or public sharing. Access follows
the existing AWS/log permissions; pseudonymous telemetry remains restricted data.

## Verification and rollout

Offline structural checks:

```sh
terraform -chdir=terraform/modules/frontend_page_visits_dashboard init -backend=false
terraform -chdir=terraform/modules/frontend_page_visits_dashboard validate
terraform -chdir=terraform/modules/frontend_page_visits_dashboard test
```

Run through the repository's direnv environment where used. CI runs the module's
mock-provider tests alongside the existing Puma dashboard module. Those tests
validate Terraform, query wiring, scope and layout; they do not execute AWS query
syntax or prove the data results.

Before deployment, with authorised staging credentials:

1. Confirm the account, region, log group/stream selector and actual field types.
2. Run all nine queries over a small, fixed window. Check results, bytes scanned
   and duration. Confirm the region supports the multi-stage Logs Insights syntax.
3. Validate sessions with 1, 2, 3, 9 and 10 requests, equal-count sessions, missing
   session IDs, duplicated HTTP IDs, repeated pages, redirects and errors. Include
   records just outside the window and excluded bot/background/auth records.
4. Compare grouped session totals and summed page requests to an independently
   computed aggregate for that same window. Check missing HTTP-ID records too.
5. Inspect both pies and every table/chart in CloudWatch, including empty results,
   readable labels and text height. Publish aggregate evidence without IDs.
6. Record collection start/coverage and query cost. Inspect the environment's
   Terraform plan: only the new dashboard should be added. Apply only with approval.

Live query execution and visual validation remain required before calling the
dashboard production-validated. The dashboard alone does not complete AI-1313.
