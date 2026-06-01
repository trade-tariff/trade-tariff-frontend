# FlagSmith Integration Design

**Date:** 2026-06-01
**Branch:** `feature/flagsmith-integration`
**Context:** Parallel comparison spike against `feature/flipper-cloud-integration`. Both branches start from `main` and replace the existing env-var-based feature flags with a managed feature flag service. This branch uses self-hosted FlagSmith; the Flipper branch uses Flipper Cloud.

---

## Goal

Replace the ad-hoc `ENV['GREEN_LANES_ENABLED']`, `WEBCHAT_URL`, and similar env-var flags with FlagSmith as the feature flag backend. Support per-identity flag evaluation (different users can get different flag values) and per-identity flag mutation (opt-in flows via the app). Produce a working implementation that can be compared directly against the Flipper Cloud branch.

---

## Approach

**SDK for evaluation, Admin API for mutations** (Approach 1).

- The `flagsmith` gem's `Flagsmith::Client` handles all flag evaluation, passing an identity string per request.
- The FlagSmith Admin REST API (via Faraday) handles writes: enabling/disabling flags for a specific identity, and reading/replicating identity overrides during anonymous→authenticated migration.
- Two credentials: an environment SDK key (evaluation) and an Admin API key (mutations).

---

## Architecture

### `FlagsmithClient`

A singleton wrapper (`app/services/flagsmith_client.rb`) around `Flagsmith::Client`. Single point of contact for all feature flag logic. Exposes:

- `flags_for(identity)` — returns a flags object for the given identity, memoised on `Current` for the request lifetime (one API call per request, not one per `feature_enabled?` call)
- `enable_for_identity(flag, identity)` — Admin API write: POST per-identity flag override with `enabled: true`
- `disable_for_identity(flag, identity)` — Admin API write: POST per-identity flag override with `enabled: false`
- `get_identity_overrides(identifier)` — Admin API read: list per-identity feature state overrides for an identity string

In test, `FlagsmithClient.instance` is replaced with an in-memory test double (see Test Support below).

### Identity model

Two plain Ruby structs in `app/models/flagsmith/`:

- `Flagsmith::AnonymousIdentity` — wraps a UUID from the `flipper_anonymous_id` cookie; produces identifier string `"Anonymous:#{uuid}"`
- `Flagsmith::UserIdentity` — wraps an email or sub claim from the JWT cookie; produces identifier string `"User:#{email_or_sub}"`

`Current.flagsmith_identity` holds the resolved identity for the request, set by `ApplicationController#set_current_flagsmith_identity`. Resolution logic:

1. Read the JWT cookie; decode claims (no signature verification — identity provider handles that)
2. If `email` or `sub` is present → `Flagsmith::UserIdentity`
3. Otherwise → `Flagsmith::AnonymousIdentity` using the `flipper_anonymous_id` cookie (lazily creating a UUID if absent, stored as a 1-year httponly cookie)

### Flag evaluation

`ApplicationHelper#feature_enabled?(flag)`:

```ruby
def feature_enabled?(flag)
  FlagsmithClient.instance.flags_for(Current.flagsmith_identity).is_feature_enabled(flag.to_s)
end
```

FlagSmith flag names are strings. The `.to_s` coercion means call sites continue using symbols (`feature_enabled?(:green_lanes)`).

### Anonymous→authenticated migration

`ApplicationController#migrate_anonymous_flagsmith_identity` runs as a `before_action`. Fires only when a user ID is present and the anonymous cookie also exists.

1. Calls `FlagsmithClient.instance.get_identity_overrides("Anonymous:#{uuid}")` — Admin API GET for per-identity overrides
2. For each override with `enabled: true`, calls `enable_for_identity` for the user identity
3. DELETEs the anonymous identity from FlagSmith via Admin API
4. Deletes the `flipper_anonymous_id` cookie

This is synchronous in the request, but fires only once (on first authenticated request after anonymous flag assignment), so latency is acceptable.

### `FeatureOptInsController`

Structurally identical to the Flipper branch. `MANAGEABLE_FEATURES` whitelist, `create`/`destroy` actions, `redirect_to_return_or_back`, `safe_local_path`. Calls route to `FlagsmithClient` instead of `Flipper`:

```ruby
FlagsmithClient.instance.enable_for_identity(flag, Current.flagsmith_identity)
FlagsmithClient.instance.disable_for_identity(flag, Current.flagsmith_identity)
```

---

## Configuration

Three environment variables:

| Variable | Purpose | Required |
|---|---|---|
| `FLAGSMITH_ENVIRONMENT_KEY` | SDK key for flag evaluation and trait writes | Yes |
| `FLAGSMITH_API_URL` | Base URL of the self-hosted instance (e.g. `https://flagsmith.example.com/api/v1`) | Yes (no default for self-hosted) |
| `FLAGSMITH_ADMIN_API_KEY` | Server-side key for Admin API mutations | Yes (for opt-in and migration) |

`config/initializers/flagsmith.rb` configures `FlagsmithClient` with these values. In test, the initialiser is skipped and the test double is used instead.

Removed env vars (flags moved to FlagSmith):
- `GREEN_LANES_ENABLED`
- `ROO_WIZARD`
- `STW_ENABLED`
- `WELSH`
- `WEBCHAT_URL`

---

## Test support

`spec/support/flagsmith.rb` installs an in-memory test double for `FlagsmithClient.instance`:

- Holds a hash of `{ flag_name => enabled }` — global defaults, all off
- Per-identity overrides supported if needed
- `before(:each)` resets all flags to off
- Admin API calls (`enable_for_identity`, `disable_for_identity`, `get_identity_overrides`) are no-ops / return empty by default; spec-level WebMock stubs available for tests that exercise mutation paths

Test helper methods (product-agnostic names):

```ruby
enable_feature(:green_lanes)    # sets flag on in the in-memory double
disable_feature(:green_lanes)   # sets flag off explicitly
```

For Capybara JS tests (Cuprite/Chrome): stub at the Ruby module level to guarantee cross-thread visibility:

```ruby
allow(FlagsmithClient.instance).to receive(:flags_for).and_return(double(is_feature_enabled: false))
allow(FlagsmithClient.instance).to receive(:flags_for)
  .with(satisfy { |id| id.identifier == 'User:...' })
  .and_return(double(is_feature_enabled: true))
```

This avoids the Puma thread-local state problem encountered in the Flipper branch.

---

## Existing call site migration

Replace env-var checks and `TradeTariffFrontend` flag methods with `feature_enabled?`:

| Before | After |
|---|---|
| `ENV['GREEN_LANES_ENABLED'].present?` | `feature_enabled?(:green_lanes)` |
| `TradeTariffFrontend.webchat_url.present?` | `feature_enabled?(:webchat)` |
| `ENV['STW_ENABLED'].present?` | `feature_enabled?(:stw)` |
| `ENV['ROO_WIZARD'].present?` | `feature_enabled?(:roo_wizard)` |
| `ENV['WELSH'].present?` | `feature_enabled?(:welsh)` |

---

## Implementation tasks (outline)

1. Add `flagsmith` gem
2. Set up test support — in-memory double, `enable_feature`/`disable_feature` helpers
3. Implement identity structs (`Flagsmith::AnonymousIdentity`, `Flagsmith::UserIdentity`)
4. Add `Current.flagsmith_identity` and `feature_enabled?` helper
5. Implement `FlagsmithClient` — evaluation wrapper + Admin API mutation methods
6. Add `set_current_flagsmith_identity` and `migrate_anonymous_flagsmith_identity` to `ApplicationController`
7. Implement `FeatureOptInsController`
8. Configure initializer (`config/initializers/flagsmith.rb`)
9. Migrate existing call sites; remove old env-var flag methods from `TradeTariffFrontend`
