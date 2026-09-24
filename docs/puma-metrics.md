# Puma request capacity metrics

The opt-in `PumaMetrics::Plugin` reports web request thread occupancy and queue
backlog. Collector behaviour is kept aligned in the frontend and backend
repositories; the plugin's application-environment lookup is repository-specific. Backend UK and XI report separately; Sidekiq does not run the
Puma server configuration and does not start this reporter.

## Enable through the application configuration secret

Add this string value to the existing **web application's configuration
secret**, not to the Sidekiq worker secret:

```json
{
  "PUMA_METRICS_ENABLED": "true"
}
```

Apply this to frontend, backend UK API and backend XI API configuration as
required. `PUMA_METRICS_SERVICE` is optional: the Puma configuration defaults it
to `frontend` or `backend-${SERVICE}` (UK when SERVICE is absent). If explicitly
set, use `frontend`, `backend-uk` or `backend-xi` to match the dashboards.

Environment comes from existing application configuration, not a separate
telemetry setting or `RAILS_ENV`. Frontend uses `TradeTariffFrontend.environment`
(the existing `ENVIRONMENT`, default `production`). Its config module can load
in the Puma master without Rails. Backend reads the same existing `ENVIRONMENT`
source and `local` fallback as `TradeTariffBackend.environment`, without booting
Rails just to read it. Staging therefore keeps its staging label even when
`RAILS_ENV=production`. No additional environment key is required.

**Changing the secret alone does not change a running process.** Follow the
normal deployment/configuration-refresh workflow so the secret values reach
the task definition and replacement tasks. These repositories currently read
configuration secrets into task environment values during Terraform execution;
a force-new-deployment of an unchanged task definition may retain old values.
This change does not modify secrets or ECS environment wiring. To disable, set
`PUMA_METRICS_ENABLED` to `false` and use the same refresh workflow.

## How collection works

- One background thread per Puma master, sampling every 10 seconds. In single
  mode the sampler runs beside the request threads in the single process.
- Uses `launcher.stats`, not a Rails endpoint, control socket, Sidekiq job or
  per-request hook. No database, metadata endpoint or AWS SDK calls.
- In cluster mode Puma already sends worker check-ins to the master. These are
  cached snapshots, not instantaneous observations at emission time.
- Unbooted/invalid workers are counted as unready. Workers with check-ins older
  than 30 seconds (or three configured check-in intervals, whichever is larger)
  are counted as stale, not as idle. Only fresh workers retain PID/index and
  check-in age in the log record; stale workers contribute to the count only.
- Emits one raw JSON line in CloudWatch Embedded Metric Format (EMF) to stdout.
  The existing ECS log pipeline must preserve that JSON as the log message.
  EMF extraction uses CloudWatch Logs; the application does not need
  `cloudwatch:PutMetricData` permission or an additional SDK dependency.
- Uses a nonblocking write with no retry or buffer. Backpressured, closed or
  failing output drops the sample. Lines larger than 4 KiB are also dropped to
  bound logging work; this comfortably covers the observed four-worker tasks.
  Unusual worker counts or oversized labels need the event size reviewed before
  enabling. On transports allowing partial writes, the affected log event may
  be unusable; it is not retried. Missing telemetry must never imply idle capacity.
- The shutdown callback wakes and stops the loop using a signal-safe queue.
  Phased worker restarts retain the single master collector. Full master
  restarts replace the process image and create a new collector identity.

This adds a small, bounded amount of CPU and log volume, not zero overhead.
Confirm ingestion and resource overhead in development/staging before production.

## Metrics and interpretation

Namespace: `TradeTariff/Puma`. Dimensions: **Environment, Service** only.
Task/collector UUID and worker PID/index are log properties, not paid metric
dimensions. Each metric therefore has bounded cardinality across task turnover.

| Metric | Meaning | Useful statistic |
| --- | --- | --- |
| `BusyThreads` | `max_threads - pool_capacity`: occupied slots, excluding queued requests | Maximum / Average |
| `AvailableThreads` | Puma's available pool capacity | Minimum / Average |
| `MaxThreads` | Configured request slots per worker | Maximum |
| `Utilization` | Busy threads divided by maximum threads, percent | Maximum / Average |
| `Backlog` | Requests in a worker's internal thread-pool queue at check-in | Maximum |
| `BacklogMax` | Puma's recorded peak backlog since previous stats reads | Maximum |
| `ExpectedWorkers` | Workers known to the master, including startup/restart workers | Maximum per task |
| `ReportingWorkers` | Fresh workers included in this sample | Minimum per task |
| `StaleWorkers` | Workers whose last check-in is too old | Maximum per task |
| `UnreadyWorkers` | Workers not booted or without usable statistics | Maximum per task |
| `SaturatedWorkers` | Fresh workers with no available request slots | Maximum per task |

Worker metrics are EMF arrays: each worker contributes a sample. Coverage
metrics are per-master scalars. **Do not use Sum over a time range for these
gauges.** It adds repeated observations, not simultaneous capacity. An Average
is a sample average, not necessarily capacity-weighted when workers differ.

Puma 8's `busy_threads` includes backlog; `running` means spawned threads. Neither
is used as the executing-request count. Puma stats reads reset its maxima;
another stats consumer can shorten the interval represented by `BacklogMax`.

These are **not queue-wait durations**. Backlog does not include every request
waiting in kernel sockets, the load balancer or another application. A slow
backend can occupy a frontend thread while the backend is still queueing.
Therefore frontend and backend occupancy cannot be added into a single shared
capacity figure. CPU, memory and downstream connection/provider limits still
matter even when thread capacity is available.

## Rollout and checks

Collection stays disabled until `PUMA_METRICS_ENABLED=true` is supplied through
the existing application configuration secret and normal refresh workflow.
Initially enable it outside production. Confirm raw `puma.metrics` events are
extracted into `TradeTariff/Puma` metrics, with the application's environment
and expected service labels. Compare reporting/expected workers with startup
logs and running tasks. Missing or stale telemetry is not spare capacity.

Check idle, saturation, recovery, full/phased restarts and log backpressure in
an approved test environment. Confirm serving and shutdown still work and
compare CPU/memory/log volume before and after collection. No production load
test is authorised by this change.

```sh
bundle exec rspec --options /dev/null spec/lib/puma_metrics_spec.rb spec/lib/puma_metrics_integration_spec.rb
bundle exec rubocop lib/puma_metrics.rb config/puma.rb spec/lib/puma_metrics*_spec.rb
```

The integration specs use real Puma, existing application configuration and a
shorter subprocess-only interval. They cover default service/environment labels,
saturation, idle recovery, full and phased restarts, HTTP serving and shutdown;
their boot path must not load Rails. The phased test disables preloading.

## Keeping the collector copies aligned

Changes to collector behaviour need a paired frontend/backend update and focused
checks in both repositories. Only the plugin's application environment lookup
and the integration specs' expected labels should differ. Compare the unit specs
byte-for-byte and review the collectors and integration specs together. No shared
package or additional runtime configuration is required.
