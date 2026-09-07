# Search analytics for Amplitude

The frontend publishes search context to `window.dataLayer`. GTM owns delivery
to GA and Amplitude. Deploying the frontend makes the properties available;
the GTM mappings and survey trigger below must also be configured and checked.

## Events

`ott_search_context` supplies the current context before GTM loads on search
pages only. Consented JSON metadata remains available on other pages for the
shared search box, but those page loads do not publish search events. Submitting
a commodity search from any page publishes the chosen mode and context,
including an autocomplete submission. This is an enrichment signal, not a search count.
An attempted submission can fail validation. Keep the existing
`ott_search_submitted` trigger and attach the context properties to its tag.
The frontend does not emit another copy of that existing event.

`ott_search_journey` reports the rendered state and Guided Search interactions.
Each event carries the complete context, so GTM can read its properties together.

| `outcome` | When it fires |
| --- | --- |
| `page_visible` | A search page becomes visible in the browser: entry, question, results, no results, unknown results, blocking guidance, or a handled guided input/backend error |
| `dont_know` | The trader submits the unknown-answer choice |
| `result_selected` | The trader selects a Guided Search commodity result |

Questions and results share `/search`. Use `search_state`, not the URL, to
distinguish them. `destination` repeats that state on journey events.

## Properties

| Property | Meaning |
| --- | --- |
| `search_experience` | `guided_beta` or `classic`, from the application's resolved flag decision |
| `search_mode` | `guided` or `keyword`, from the actual journey or initial form choice |
| `search_state` | `entry`, `submitted`, `question`, `results`, `no_results`, `unknown_results`, `blocking_guidance`, `input_error`, `backend_error`; null outside search |
| `feature_flag_name` | `interactive_search` |
| `feature_flag_enabled` | Boolean effective decision, including service restrictions and defaults |
| `feature_flag_source` | `flagsmith` or `default` |
| `feature_flag_fallback_reason` | Null after successful evaluation; otherwise `missing_flag`, `unavailable`, `not_configured`, `missing_identity`, `unsupported_service` or `missing_evaluation` |
| `request_id` | Existing search request ID, including the backend-returned Guided Search ID; null before a request has been assigned |
| `experiment` | Existing server-resolved experiment label, or null |
| `question_count` | Answered questions plus the current pending question |
| `option_count` | Options on the current pending question, excluding the UI's extra unknown-answer choice |
| `result_count` | Results returned for the current search |
| `used_dont_know` | True on the unknown-answer event; false on other events |
| `client_elapsed_ms` | Time spent on the question before submitting, or before choosing the unknown answer |
| `client_navigation_ms` | Guided submit-to-visible duration when a submission timestamp is available; otherwise null |
| `result_rank` | One-based rank of the selected Guided Search result |
| `confidence` | Confidence of the selected result, such as `strong`, `good` or `unknown` |
| `goods_nomenclature_item_id` | Selected commodity code |

Unused fields are explicitly null to clear previous values in GTM. A new
search submission clears previous result counts, rank, confidence and request
ID. A numeric keyword query still has `search_mode = keyword`; there is no
commodity-code search mode. A beta trader choosing keyword search remains
`search_experience = guided_beta`.

An unavailable flag evaluation must not be counted as an intentional control
assignment. For beta/control analysis, filter to `feature_flag_source = flagsmith`
before comparing the experience values. The effective experience is still
reported for default decisions because it describes what the trader received.

## GTM and Amplitude setup

1. Create Data Layer Variables for the properties above using the exact keys.
2. Add `search_experience`, `search_mode`, the four `feature_flag_*` properties
   and `experiment` to the existing `ott_search_submitted` tag. Keep its current
   Search Term, Search Type, Search Origin, Journey and Unique Search ID mapping.
   Add `request_id` where available on destination events for correlation.
3. Create a Custom Event trigger for `ott_search_journey`. Send that event and
   its non-null properties through the existing Amplitude browser tag. If GA
   is also required, map the same properties to its event tag.
4. Ensure Guides & Surveys receives the browser event. With the Amplitude GTM
   template, enable Guides & Surveys in the SDK setup. With standalone
   engagement initialization, configure event forwarding after it boots:

   ```javascript
   window.engagement.forwardEvent({
     event_type: 'ott_search_journey',
     event_properties: propertiesFromThisDataLayerEvent,
   });
   ```

   Use the configured SDK integration or standalone forwarding once. Avoid
   forwarding a second copy when the Amplitude integration already does it.
   A GA export or server ingestion alone does not provide this browser trigger.
5. Configure the survey's event trigger with:

   ```text
   event = ott_search_journey
   outcome = page_visible
   search_state = results
   search_experience = guided_beta
   feature_flag_source = flagsmith
   feature_flag_enabled = true
   ```

   Add `search_mode = guided` only if the survey should exclude beta traders
   who chose keyword search. Include `no_results` or `unknown_results` only
   if those states are explicitly in the survey audience.

Keep these properties on events. A persistent user property could retain an
old beta assignment after the flag or service changes.

References: [Google's data layer contract](https://developers.google.com/tag-platform/tag-manager/datalayer),
[Amplitude GTM template](https://amplitude.com/docs/data/source-catalog/google-tag-manager),
[Guides & Surveys event forwarding](https://www.amplitude.com/docs/sdks/guides-and-surveys/sdk).

## Consent and scope

The context is rendered only with usage-cookie consent. Browser events also
check current consent, so revoking it stops new events on an already loaded
page. Analytics receives no raw questions, options, answers or expanded search
text, no Flagsmith identity or traits, and no new trader identifier. The new
payload does not copy the search term; its existing GTM mapping is unchanged.
No analytics properties are added to URLs, links or form parameters.

Existing server-side `guided_search.journey` monitoring is independent of GTM
and analytics consent. The new event does not replace those server requests.
Exact classic matches that redirect to a commodity page are not a rendered
search-results state and do not trigger the results survey.

## Verification before closing AI-1271

Repository request and browser tests verify the emitted payload and consent.
They do not verify a remote GTM container or Amplitude project configuration.

In GTM Preview, check beta guided, beta keyword and classic sessions. Confirm
the existing submitted event sees the correct experience/mode, including
autocomplete, and that `ott_search_journey` fires once per rendered page.
Check the question, results, no-results and guidance states separately.
On a non-search page, confirm neither search event fires on load, then submit
the shared commodity search and check its context is published before the
existing submitted event. Quota and chemical searches must not publish it.

In Amplitude, inspect the received event properties and verify a test survey
appears only on the intended results state. Check a default/unavailable flag
and rejected usage cookies are excluded. Keep AI-1271 open until this live
check and the Guides & Surveys forwarding check have passed.
