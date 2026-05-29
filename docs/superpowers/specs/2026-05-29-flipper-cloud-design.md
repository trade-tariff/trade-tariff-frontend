# Flipper Cloud Feature Flag Integration

**Date:** 2026-05-29
**Status:** Approved

## Overview

Integrate [Flipper Cloud](https://www.flippercloud.io) into the Frontend Rails app to replace the current ENV-var-based feature flags. The integration enables percentage rollouts, per-user opt-in, and globally toggled flags — all without deploys. All existing flags are migrated.

## Goals

- Toggle features at runtime without a code deploy
- Roll out features to a percentage of users
- Allow users to opt into features explicitly
- Support date-embargoed features (manual switch in Flipper Cloud UI)
- Consistent flag state for authenticated users across devices
- Best-effort flag state for anonymous users on a single device

## Non-goals

- Automated date-embargo activation (humans flip the switch)
- Cross-device opt-in persistence for anonymous users
- A standalone beta features page (opt-in is an inline contextual button)

---

## Adapter Layering

Three gems are added: `flipper-cloud`, `flipper-redis`, `flipper-rails`.

```
Flipper Cloud  ←→  /flipper/webhooks (signed with FLIPPER_CLOUD_SYNC_SECRET)
      ↓ pushes full feature state on every flag change
Flipper::Adapters::Redis  (persistent store — survives app restarts)
      ↑ wrapped per-request by
Flipper::Adapters::Memoizable  (in-process cache, cleared after each request)
```

Normal flag reads hit the memoizable cache — Redis is consulted at most once per flag per request. Flipper Cloud is never in the hot path. If Flipper Cloud is unreachable, Redis holds the last-known state and the app continues normally. If the app restarts while Flipper Cloud is also down, Redis seeds the initial state.

`flipper-rails` wires up the Memoizable middleware automatically.

```ruby
# config/initializers/flipper.rb
redis_adapter = Flipper::Adapters::Redis.new(Redis.new(url: ENV['REDIS_URL']))

Flipper.configure do |config|
  config.adapter do
    Flipper::Cloud.new(
      ENV.fetch('FLIPPER_CLOUD_TOKEN'),
      sync_secret: ENV.fetch('FLIPPER_CLOUD_SYNC_SECRET'),
      local_adapter: redis_adapter,
    )
  end
end
```

The webhook endpoint is mounted in `routes.rb` as a small Rack app. Flipper Cloud signs each push with `FLIPPER_CLOUD_SYNC_SECRET`; unsigned requests are rejected automatically.

### Multiple instances

All app instances share the same Redis. The memoizable cache is per-request (cleared after every response), not per-process. When Flipper Cloud pushes a webhook, it hits whichever instance the load balancer routes it to — that instance writes to shared Redis. All other instances read the updated state on their next request. Propagation delay is at most the duration of one in-flight request.

The webhook endpoint must be exempted from `rack-attack` rate limiting.

---

## Actor Model

Flipper gates operate against an actor — any object responding to `flipper_id`.

### Authenticated users

Identified by the user ID decoded from the JWT cookie. Flag state follows the user across all devices.

```ruby
class Flipper::UserActor
  def initialize(user_id)
    @user_id = user_id
  end

  def flipper_id
    "User:#{@user_id}"
  end
end
```

### Anonymous users

Identified by a UUID stored in a long-lived cookie (`flipper_anonymous_id`), generated on first visit. Flag state is device-specific — if the user switches browsers or clears cookies, they get a fresh UUID.

```ruby
class Flipper::AnonymousActor
  def initialize(uuid)
    @uuid = uuid
  end

  def flipper_id
    "Anonymous:#{@uuid}"
  end
end
```

### Actor resolution

`ApplicationController` resolves the correct actor and exposes it via `current_flipper_actor`:

```ruby
def current_flipper_actor
  if authenticated?
    Flipper::UserActor.new(current_user_id)
  else
    Flipper::AnonymousActor.new(anonymous_flipper_id)
  end
end

def anonymous_flipper_id
  cookies[:flipper_anonymous_id] ||= SecureRandom.uuid
end
```

### Anonymous-to-authenticated migration

Since login is handled externally, there is no discrete sign-in event to hook into. Migration is lazy: on any authenticated request where `flipper_anonymous_id` cookie is also present, the anonymous actor's opt-ins are copied to the user actor, then the cookie is cleared.

```ruby
# ApplicationController
before_action :migrate_anonymous_flipper_actor

def migrate_anonymous_flipper_actor
  return unless authenticated?
  return unless cookies[:flipper_anonymous_id].present?

  anonymous_actor = Flipper::AnonymousActor.new(cookies[:flipper_anonymous_id])
  user_actor      = Flipper::UserActor.new(current_user_id)

  Flipper.features.each do |feature|
    feature.enable_actor(user_actor) if feature.enabled?(anonymous_actor)
  end

  cookies.delete(:flipper_anonymous_id)
end
```

Migration is idempotent. After the cookie is cleared, subsequent authenticated requests skip the before-action early.

---

## Flag Interface

A single `feature_enabled?(flag)` helper is added to `ApplicationController` and exposed to views via `helper_method`. No per-flag method needs to be created — adding a new flag in Flipper Cloud just works. All call sites use the same interface regardless of whether the flag is global, percentage-based, or actor-targeted.

```ruby
# ApplicationController
helper_method :feature_enabled?

def feature_enabled?(flag)
  Flipper.enabled?(flag.to_sym, current_flipper_actor)
end
```

Usage in controllers and views:

```ruby
feature_enabled?(:green_lanes)
feature_enabled?(:roo_wizard)
```

The existing per-flag methods on `TradeTariffFrontend` (`green_lanes_enabled?`, `roo_wizard?`, etc.) are removed entirely. All call sites are updated to use `feature_enabled?` instead.

If called outside a request context (rake tasks, background jobs), `current_flipper_actor` returns nil and Flipper performs a global check — the flag is only considered enabled if it is on for everyone.

---

## Flag Migration

All existing ENV-based flags are migrated to Flipper Cloud. The ENV vars are removed entirely — no dual-path fallback.

**Migration sequence (to avoid disabling live features):**

1. Create each flag in Flipper Cloud and set it to match its current production state before deploying any code changes
2. Deploy the Flipper integration — remove `TradeTariffFrontend` flag methods, update all call sites to `feature_enabled?`
3. Remove the now-unused ENV vars from infrastructure config in a follow-up

| Old call site | ENV var | Flipper flag | New call site |
|---|---|---|---|
| `TradeTariffFrontend.green_lanes_enabled?` | `GREEN_LANES_ENABLED` | `:green_lanes` | `feature_enabled?(:green_lanes)` |
| `TradeTariffFrontend.roo_wizard?` | `ROO_WIZARD` | `:roo_wizard` | `feature_enabled?(:roo_wizard)` |
| `TradeTariffFrontend.interactive_search_enabled?` | *(logic-based)* | `:interactive_search` | `feature_enabled?(:interactive_search)` |
| `TradeTariffFrontend.single_trade_window_linking_enabled?` | `STW_ENABLED` | `:single_trade_window` | `feature_enabled?(:single_trade_window)` |
| `TradeTariffFrontend.webchat_enabled?` | `WEBCHAT_URL` | `:webchat` | `feature_enabled?(:webchat)` |
| `TradeTariffFrontend.welsh?` | `WELSH` | `:welsh` | `feature_enabled?(:welsh)` |

---

## Opt-in Mechanism

Users opt into a feature via a contextual button rendered inline within the relevant feature's UI. The button POSTs to a generic controller that adds the current actor to the flag's actor list.

```ruby
# app/controllers/feature_opt_ins_controller.rb
class FeatureOptInsController < ApplicationController
  def create
    Flipper.enable_actor(params[:feature].to_sym, current_flipper_actor)
    redirect_back fallback_location: root_path
  end

  def destroy
    Flipper.disable_actor(params[:feature].to_sym, current_flipper_actor)
    redirect_back fallback_location: root_path
  end
end
```

The controller is generic — any opt-in-able feature passes its flag name as the `feature` param. The flag name should be validated against a known allowlist to prevent arbitrary actor-enables on undefined flags.

---

## Date Embargoes

Flipper Cloud has no native scheduled activation. Embargoed features are enabled manually in the Flipper Cloud UI by a team member on or around the embargo date. No automated mechanism is built.

---

## Environment Variables

Two new variables are required:

| Variable | Purpose |
|---|---|
| `FLIPPER_CLOUD_TOKEN` | Authenticates the app with Flipper Cloud |
| `FLIPPER_CLOUD_SYNC_SECRET` | Validates incoming webhook payloads from Flipper Cloud |

`REDIS_URL` is already configured.

---

## Testing

Tests use the memory adapter — no Redis, no Flipper Cloud:

```ruby
# spec/support/flipper.rb
RSpec.configure do |config|
  config.before do
    Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new)
  end
end
```

All flags default to `false`. Tests that require a flag declare it explicitly:

```ruby
before { Flipper.enable(:green_lanes) }

# actor-specific
before { Flipper.enable_actor(:new_feature, Flipper::UserActor.new('user-123')) }
```

Existing specs that stub `TradeTariffFrontend.green_lanes_enabled?` directly are updated to use `Flipper.enable` instead. Behaviour is identical. Specs that test `feature_enabled?` through a controller or view need no special setup beyond enabling the relevant flag.
