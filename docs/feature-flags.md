# Feature flags

Feature flags are evaluated via [LaunchDarkly](https://launchdarkly.com). The
integration lives in `lib/trade_tariff_frontend/feature_flag.rb` and is
designed so that developers never need to interact with the LaunchDarkly SDK
directly.

## Quick start

### Declaring a flag

All flags must be declared in `REGISTRY` before use. Add an entry with a safe
default — the value returned when LaunchDarkly is unreachable or the SDK key
is not configured:

```ruby
# lib/trade_tariff_frontend/feature_flag.rb
REGISTRY = {
  my_new_feature: false,  # off by default
  # ...
}.freeze
```

The flag key must match the flag key configured in the LaunchDarkly dashboard.

### Checking a flag

From anywhere in the application:

```ruby
TradeTariffFrontend::FeatureFlag.enabled?(:my_new_feature)  # => true / false
TradeTariffFrontend::FeatureFlag.disabled?(:my_new_feature) # => false / true
```

From a controller or view (available via the `FeatureFlaggable` concern, which
is included in `ApplicationController`):

```erb
<% if feature_enabled?(:my_new_feature) %>
  <%# render the new thing %>
<% end %>
```

```ruby
# app/controllers/my_controller.rb
feature_gate :my_new_feature
```

`feature_gate` sets up a `before_action` that raises
`TradeTariffFrontend::FeatureUnavailable` when the flag is off, preventing the
action from running. It accepts the same options as `before_action`:

```ruby
feature_gate :my_new_feature, only: :show
feature_gate :my_new_feature, except: %i[index show]
```

### Guarding a whole controller

```ruby
class MyNewController < ApplicationController
  feature_gate :my_new_feature

  def index
    # only reached when my_new_feature is on
  end
end
```

### Guarding specific actions

```ruby
class MyController < ApplicationController
  feature_gate :my_new_feature, only: :new_action

  def existing_action
    # always reachable
  end

  def new_action
    # only reached when my_new_feature is on
  end
end
```

---

## How it works

### Evaluation

`FeatureFlag.enabled?` calls `LDClient#variation` with:

1. **Flag key** — the symbol name as a string, e.g. `"my_new_feature"`.
2. **Evaluation context** — see below.
3. **Default value** — the value from `REGISTRY` for that flag.

The default is returned whenever LaunchDarkly cannot be reached (network error,
slow start-up, or offline mode — see below).

### Evaluation context

Every flag evaluation sends a **multi-context** to LaunchDarkly carrying two
independent dimensions:

**`application` context** — fixed attributes about the deployment:

- `service` — `"uk"` or `"xi"`, reflecting the active service variant.
- `environment` — the value of the `ENVIRONMENT` env var (e.g. `"production"`,
  `"staging"`, `"development"`).

Use this context in LaunchDarkly targeting rules to scope a flag to a specific
environment or service without encoding that logic into the flag name itself,
e.g. "enable this flag only when `environment` is `staging`".

**`user` context** — an anonymous, session-scoped identifier:

- A UUID generated once per session and stored in `session[:ld_anonymous_id]`.
- Marked `anonymous: true`; carries no PII.
- Stable for the lifetime of the session, so the same visitor consistently lands
  in the same percentage bucket on every request.

Use this context in LaunchDarkly targeting rules for **percentage rollouts** —
e.g. "enable for 10% of users". LaunchDarkly hashes the user key into a bucket,
so rollout decisions are consistent per visitor rather than random per request.

When `FeatureFlag.enabled?` is called outside a request context (e.g. from a
background job or a Rake task), pass `user_key: nil` (the default) and only the
`application` context is sent — no multi-context is built.

### Offline mode

When `LAUNCHDARKLY_SDK_KEY` is absent or blank the SDK client is initialised in
offline mode. `variation` then returns the `REGISTRY` default for every flag
without making any network calls. This means:

- Local development works without a LaunchDarkly account or SDK key.
- Test suites run without any external dependencies.
- All flags default to **off** (safe) unless the registry says otherwise.

### Unknown flags

Calling `enabled?` or `disabled?` with a flag name not in `REGISTRY` raises
`TradeTariffFrontend::FeatureFlag::UnknownFlagError` immediately. This catches
typos at development time rather than silently returning `false` at runtime.

---

## Testing

### Stubs

Use `stub_feature_flag` (available in all specs via `spec/support/feature_flags.rb`):

```ruby
# Enable a flag for the duration of one example
stub_feature_flag(:my_new_feature)                    # enabled: true is the default
stub_feature_flag(:my_new_feature, enabled: true)
stub_feature_flag(:my_new_feature, enabled: false)
```

Other flags are unaffected and continue to return their `REGISTRY` defaults.

### Without stubs

In specs that do not call `stub_feature_flag`, every flag returns its `REGISTRY`
default (offline mode). If the default is `false`, the flag is off. This is the
expected baseline for most tests.

---

## Operations

### Setting a flag in LaunchDarkly

1. Create the flag in the LaunchDarkly dashboard with the same key used in
   `REGISTRY` (snake_case, e.g. `my_new_feature`).
2. To target by environment or service, add rules on the **`application`**
   context kind using the `environment` or `service` attributes.
3. To do a percentage rollout, add a rule on the **`user`** context kind and
   set the percentage. LaunchDarkly will consistently hash each anonymous
   session UUID into the same bucket.
4. The application polls LaunchDarkly continuously; changes take effect within
   seconds without a deploy.

### Environment variable

| Variable               | Required | Description                                                                                           |
| ---------------------- | -------- | ----------------------------------------------------------------------------------------------------- |
| `LAUNCHDARKLY_SDK_KEY` | No       | Server-side SDK key. When absent, offline mode is used and all flags return their `REGISTRY` defaults. |

### Migrating an existing ENV-based flag

The existing `TradeTariffFrontend.green_lanes_enabled?` style methods continue
to work. To migrate one to LaunchDarkly:

1. Ensure the flag is in `REGISTRY`.
2. Replace the `ENV` check at each call site with `FeatureFlag.enabled?(:flag)`.
3. Remove the old method from `lib/trade_tariff_frontend.rb`.
4. Remove the corresponding env var from deployment configuration.
