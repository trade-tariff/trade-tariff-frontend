# Feature flags and manual preferences

The browser keeps an anonymous identity in the `flagsmith_anonymous_id` cookie for up to one year. Manual opt-ins are boolean traits stored against that identity in Flagsmith core. The Rails session is not a source of manual preferences.

On the first flag evaluation in a request, Rails reads persisted traits from core. It forwards only boolean traits for registered opt-in features to Edge. Current country and active experiment enrolments are transient request traits. An active experiment can supply an opt-in even when the saved manual preference is false.

Edge evaluates the combined inputs against its rollout configuration. A saved opt-in is not a direct feature override. Service restrictions, including the guided-search XI exclusion, still apply. Preferences and evaluated flags are cached only for the current request.

`/feature-flags` shows two separate values:

- **Saved preference:** the identity trait in core. The button changes this value.
- **Available now:** the same effective feature check used by the application, including service restrictions and configured fallbacks.

Removing a manual opt-in does not exclude the identity from an automatic rollout or an active experiment. Experiment URL enrolments remain session-bound and time-limited. Percentage allocation remains an Edge decision based on the identity and current request traits.

## Operational consequences

Each request that evaluates flags adds a core lookup before the Edge evaluation. The core SDK identity endpoint also creates a database identity for previously unseen browsers. This increases core traffic and stored identity volume compared with Edge-only evaluation. Check core latency and capacity before deployment.

If the core preference lookup fails, flag evaluation uses the existing application fallback. Guided search is disabled in production for that request, including for automatic rollout users. A failed lookup is not retried within the same request. The settings page reports a load failure rather than presenting missing preferences as an opt-out.

Existing saved manual opt-ins become effective after deployment even if their old Rails session has expired. No preference migration is required. Losing the anonymous identity cookie creates a new identity without the old preferences; it does not delete the old database record.

## Source anchors

- `app/controllers/concerns/flagsmith_setup.rb`
- `app/services/flagsmith/opt_in_preferences.rb`
- `app/services/flagsmith_management_client.rb`
- `lib/trade_tariff_frontend/flagsmith_backed_config.rb`
- `app/controllers/feature_flags_controller.rb`
