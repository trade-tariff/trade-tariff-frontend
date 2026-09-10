# Queued guided search (AI-1314)

## Problem and approach

Guided search can occupy frontend and backend Puma threads while retrieval and AI providers work. Moving execution into Sidekiq removes that long search wait from the web tiers. Staggering polling is a separate, smaller optimisation: it takes the edge off repeated browser-to-frontend-to-backend status calls while the job runs.

A pending status check normally makes a frontend request, a backend request and a backend Redis read, with a frontend cache lookup too. Those are short operations, but repeated checks still consume request slots, connections and processing. Polling less often reduces that traffic; it does not make the underlying search faster or reduce its provider work.

There is no new runtime feature flag. Deploying the caller activates queued submission wherever guided search is already available. Classic search and no-JavaScript submissions retain their existing synchronous paths.

## Request flow and ownership

1. Existing form validation runs and the existing throbber becomes visible.
2. CSRF-protected `POST /search/queued` checks current guided-search eligibility, validates inputs and merges the current answer. It submits a real backend job.
3. Rails returns the backend ID, an expiring signed token, resolved date, request ID and polling URL. The token binds the job, UK service and canonical input fingerprint to the existing Rails session ID.
4. `GET /search/queued/:id?token=...` verifies the token before consulting the result cache or backend. It returns only lifecycle state and skips page setup and Flagsmith evaluation.
5. On completion, JavaScript posts the original form with `queued_search_id` and `queued_search_token`. Rails checks ownership and the input fingerprint, then renders the stored result using the existing question/results routing. It does not execute search again.

**No per-job ownership data goes into cookies.** IDs and tokens travel in the response, polling URL and form body, not a session collection. The token contains a fingerprint, not the query or answers. It expires after one hour. Concurrent submissions do not overwrite an ownership list; a changed/expired session or invalid token cannot retrieve the job. Tokens grant access, not an admission-control or concurrency limit.

Current eligibility is checked for **every new submission**, including follow-up answers. Disabling guided search prevents new work but lets a previously accepted step finish with its valid grant. Polling therefore does not repeat remote Flagsmith identity calls. Ordinary page/final-navigation setup can still evaluate flags; these are not zero-dependency requests.

The submission's resolved date is retained through final handoff, including nested Rails date fields and crossing midnight. Back-forward cache restoration restores or removes the added handoff fields so they cannot silently override a newly edited date.

## Results, cache and recovery

- Every accepted ID identifies a real backend job. The earlier synthetic-ID warm-cache shortcut has been removed. Explicitly submitting again can create another job; a synchronous search-cache entry is not an acceptance source.
- Validated completed results are cached per backend job for 30 minutes, avoiding repeat backend reads during polling and final rendering. Cache loss or decoding failure falls back to that job, not another search. Cache serialization failure does not prevent rendering a valid result.
- Malformed completed envelopes, resource shapes or consumed metadata produce recovery, not a cached success or misleading no-results page. Backend request identifiers retain the existing 64-character restriction; pending questions need selectable, nonblank options. Exclusion copy remains optional: without both message fields, preserve the existing no-results route.
- Only explicit pre-enqueue `validation_failed: true` responses use the ordinary form post to preserve existing GOV.UK field/date errors. Generic 422s, CSRF failures and execution/network errors never silently start synchronous search.
- Failure restores inputs and focuses a visible recovery summary. Retry is under trader control. The throbber remains mounted and visible throughout successful polling.
- An expired backend result at final handoff produces recovery. A signed token cannot guarantee that a worker survived or a result still exists.
- Polling and queued-result responses are `no-store`; existing parameter filtering redacts token parameters from application logs.

## Polling schedule

Elapsed times from submission, not successive delays:

```text
0.25s, 1s, 5s, 7s, 10s, 12s, 15s, then every 5s through 115s.
```

Use a monotonic clock. Late acceptance gets one immediate check; slow responses skip missed slots rather than triggering catch-up bursts. Polls never overlap. `queued` and `running` use the same clock because neither exposes the processing stage or an ETA.

Transient polling errors use separate bounded backoff of two then four seconds, stopping after three consecutive errors. Transport-level safe-method retries can make additional backend attempts. Ambiguous submission failures are never automatically retried.

**The 120-second limit covers acceptance and polling, not final HTML navigation.** That timer is cancelled before native form submission. Final navigation can take additional time. Navigation/disconnection aborts browser requests and timers, and stale responses cannot affect a new run; none of this cancels backend execution.

## Evidence behind the cadence

Source: `guided-search-experiment-report.pdf` and `guided-search-mon-fri-key-events.csv` attached to [AI-1093](https://transformuk.atlassian.net/browse/AI-1093), covering 27-31 July 2026. The PDF reports roughly 13 seconds mean service time, 9 seconds median and 24 seconds p90. The typical browser-visible question wait was around 10 seconds, not a guaranteed 13-second completion time.

An idealised replay of 318 completed non-exact steps gives:

| Schedule | Mean status checks | Mean polling-added delay | p95 polling-added delay |
| --- | ---: | ---: | ---: |
| Immediately, then every second | 14.64 | 0.48s | 0.94s |
| 0.25/1/5/7/10/15s, then every 5s | 5.92 | 2.00s | 4.60s |
| Selected: also check at 12s | 6.22 | 1.60s | 4.29s |

The 12-second check catches 42 steps that finished between 10 and 12 seconds. The selected schedule models about **58% fewer status checks**, at about **1.12 seconds extra mean detection delay** versus one-second polling. This is not a reduction in all requests, CPU usage or total service load.

For reproduction, select `event=search_completed`, `search_type=interactive`, `results_type=hybrid`; convert `total_duration_ms` to seconds. Detection is the first scheduled check at or after completion; count checks through detection and subtract completion time for polling delay. Percentiles use linear interpolation. This excludes ten exact matches, unfinished/failed work, new queue waits and network/rendering overhead. It is historical modelling, not measured current async latency.

None of those 318 steps finished within two seconds. The two early checks are a deliberate allowance for backend fast paths, not a finding from that filtered sample. A result ready at two seconds waits until five seconds; tail gaps can add almost five seconds.

Backend inspection supports this distinction: description exclusions and exact matches can finish before retrieval; empty shortlists and single-result answers avoid question generation but still wait for retrieval. Hybrid retrieval joins both legs, expansion can add another pass, and provider retries mean failures are not uniformly fast. Lifecycle status provides no stage information. See the backend's `Api::Internal::SearchService`, `HybridRetrievalService` and `docs/architecture/queued-internal-search.md` for the execution contract and budgets.

## Revisit when the data changes

This is a **data-informed starting point, not a permanent service contract**. Reassess it after changes to models/providers, retrieval, caching, worker capacity, queue waits, traffic mix or error patterns. Faster searches may make the one-to-five-second gap frustrating; longer queue waits may move useful checks later.

Use representative initial and follow-up timings, including exact matches, intercepts, empty results, failures, timeouts and abandoned work. Compare status-call counts, backend-completion-to-visible-result delay and unrelated-request latency in both web tiers. Separate queue time, execution time and polling delay instead of optimising against one average. Replay candidates, then verify in a bounded real-stack trial. Update this rationale, its source window and scheduling tests together.

## Delivery and remaining limits

Deploy the backend API and **all workers containing `QueuedSearchWorker` before this frontend**. Classification logic and tariff content are unchanged. Reverting the frontend caller is the rollback boundary; accepted jobs can continue.

Keep activation to a controlled environment with bounded traffic until shared-worker impact is understood. The default Sidekiq queue is shared. Its worker has no job retries, but providers can retry internally, beyond the browser deadline. Redis retains jobs for one hour; expiry does not terminate execution. Queue fairness, admission control, provider limits, abandoned/duplicate work and polling bursts without jitter remain unproven.

## Source anchors

- `app/controllers/concerns/queued_guided_searchable.rb`: acceptance, authorisation and handoff.
- `app/services/guided_search/queued_search_token.rb`: expiring session-bound grants.
- `app/services/guided_search/queued_search.rb`: backend client and response validation.
- `app/javascript/controllers/queued_search_controller.js`: cadence, cancellation and recovery.

## Verification and benchmark

```sh
yarn jest --runInBand
bundle exec rspec spec --tag '~js'
RAILS_ENV=test bin/rails assets:precompile
bundle exec rspec spec/features/search_spec.rb spec/features/revised_find_commodities_spec.rb spec/features/search_analytics_spec.rb
bundle exec rubocop
bundle exec rspec script/benchmarks/queued_guided_search_spec.rb
```

Compile assets before browser/view tests and use the project test environment, not inherited development API/auth settings. Browser verification should use the configured local browser; workstation-specific evidence belongs in review notes rather than this architecture contract.

The opt-in benchmark uses real Rails with one Puma thread and a two-second backend stub. It deliberately retains **one-second polling**, not the current Stimulus schedule. Submission and final-HTML receipt timestamps are captured independently of the concurrent healthcheck; deterministic regressions guard that separation. Samples are written to `/tmp/queued-guided-search-benchmark.json`.

A corrected three-trial local run recorded median unrelated-request latency of 2,017.2 ms synchronously versus 6.6 ms queued, and median returned-HTML time of 2,021.3 ms versus 2,054.4 ms. This supports the contention mechanism in that synthetic case only. Flagsmith is doubled, backend/provider execution is stubbed, and these are neither browser paint timings nor production percentiles. Do not apply the small total-time difference to staggered polling or claim current capacity from it.
