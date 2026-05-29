# Flipper Cloud Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace ENV-var feature flags with Flipper Cloud, enabling runtime percentage rollouts, per-actor targeting, and user opt-in without deploys.

**Architecture:** Flipper Cloud is the authoritative source, syncing state to a shared Redis adapter via signed webhooks. All reads go through a per-request in-process memoizable cache backed by Redis — Flipper Cloud is never in the hot path. A `feature_enabled?(flag)` helper in `ApplicationHelper` gives controllers and views a single, actor-aware interface with no per-flag method needed.

**Tech Stack:** `flipper-cloud`, `flipper-redis`, `flipper-rails`, Rails 8.1, Redis (existing), JWT (existing gem)

**Spec:** [`docs/superpowers/specs/2026-05-29-flipper-cloud-design.md`](../specs/2026-05-29-flipper-cloud-design.md)

---

## File Map

| File | Action | Purpose |
|---|---|---|
| `Gemfile` | Modify | Add flipper-cloud, flipper-redis, flipper-rails |
| `spec/support/flipper.rb` | Create | Reset Flipper to memory adapter before each test |
| `app/models/flipper/user_actor.rb` | Create | Authenticated user actor (`User:<id>`) |
| `app/models/flipper/anonymous_actor.rb` | Create | Anonymous visitor actor (`Anonymous:<uuid>`) |
| `spec/models/flipper/user_actor_spec.rb` | Create | Unit tests for UserActor |
| `spec/models/flipper/anonymous_actor_spec.rb` | Create | Unit tests for AnonymousActor |
| `app/models/current.rb` | Create | `Current.flipper_actor` thread-local attribute |
| `app/helpers/application_helper.rb` | Modify | Add `feature_enabled?(flag)` |
| `app/controllers/application_controller.rb` | Modify | Set `Current.flipper_actor`, add actor resolution, migration before-action |
| `config/initializers/flipper.rb` | Create | Configure Flipper Cloud + Redis adapter |
| `config/routes.rb` | Modify | Mount Flipper Cloud webhook engine + opt-in routes |
| `config/initializers/rack_attack.rb` | Modify | Exempt webhook endpoint from rate limiting |
| `app/controllers/feature_opt_ins_controller.rb` | Create | Actor opt-in/out for individual flags |
| `spec/requests/feature_opt_ins_controller_spec.rb` | Create | Request specs for opt-in controller |
| `app/models/search.rb` | Modify | Replace `TradeTariffFrontend.interactive_search_enabled?` |
| `app/controllers/find_commodities_controller.rb` | Modify | Replace flag call |
| `app/controllers/application_controller.rb` | Modify | Replace flag calls (also covered above) |
| `app/controllers/search_controller.rb` | Modify | Replace flag call |
| `app/controllers/green_lanes/category_assessments_controller.rb` | Modify | Replace flag call |
| `app/controllers/concerns/interactive_searchable.rb` | Modify | Replace flag call |
| `app/views/shared/_stw_link.html.erb` | Modify | Replace flag call |
| `app/views/shared/webchat_message/_not_found.html.erb` | Modify | Replace flag call |
| `app/views/shared/webchat_message/_footer.html.erb` | Modify | Replace flag call |
| `app/views/shared/webchat_message/_help.html.erb` | Modify | Replace flag call |
| `app/views/search/_interactive_support_links.html.erb` | Modify | Replace flag call |
| `app/views/search/_interactive_error_sidebar.html.erb` | Modify | Replace flag call |
| `app/views/search/_interactive_results_sidebar.html.erb` | Modify | Replace flag call |
| `app/views/measures/_measures.html.erb` | Modify | Replace flag call |
| `lib/trade_tariff_frontend.rb` | Modify | Remove all flag methods and their ENV vars |
| Multiple spec files (see Task 9) | Modify | Replace `allow(TradeTariffFrontend)` stubs with `Flipper.enable` |

---

## Task 1: Add Flipper gems

**Files:**
- Modify: `Gemfile`

- [ ] **Step 1: Add gems to Gemfile**

  Open `Gemfile` and add after the `gem 'redis'` line:

  ```ruby
  gem 'flipper-cloud'
  gem 'flipper-redis'
  ```

  Note: `flipper-rails` (0.1.0) is an old third-party gem incompatible with flipper-cloud 1.4.2 — do not add it. The `flipper` gem handles its own Rails lifecycle via the initializer in Task 7.

- [ ] **Step 2: Install**

  ```bash
  bundle install
  ```

  Expected: locks three new gems without conflicts.

- [ ] **Step 3: Commit**

  ```bash
  git add Gemfile Gemfile.lock
  git commit -m "Add flipper-cloud, flipper-redis, flipper-rails gems"
  ```

---

## Task 2: Set up Flipper test support

**Files:**
- Create: `spec/support/flipper.rb`

`spec/spec_helper.rb` already auto-requires everything under `spec/support/`, so no extra wiring is needed.

- [ ] **Step 1: Create the support file**

  ```ruby
  # spec/support/flipper.rb
  RSpec.configure do |config|
    config.before do
      Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new)
    end
  end
  ```

  This resets Flipper to a clean in-memory adapter before every example. All flags start `false`. Tests that need a flag enabled do so explicitly with `Flipper.enable(:flag_name)`.

- [ ] **Step 2: Verify it loads without error**

  ```bash
  bundle exec rspec --dry-run 2>&1 | head -5
  ```

  Expected: no `LoadError` or `NameError`.

- [ ] **Step 3: Commit**

  ```bash
  git add spec/support/flipper.rb
  git commit -m "Add Flipper memory adapter reset for test isolation"
  ```

---

## Task 3: Implement actor classes

**Files:**
- Create: `app/models/flipper/user_actor.rb`
- Create: `app/models/flipper/anonymous_actor.rb`
- Create: `spec/models/flipper/user_actor_spec.rb`
- Create: `spec/models/flipper/anonymous_actor_spec.rb`

- [ ] **Step 1: Write failing tests**

  ```ruby
  # spec/models/flipper/user_actor_spec.rb
  RSpec.describe Flipper::UserActor do
    describe '#flipper_id' do
      it 'returns a namespaced user identifier' do
        expect(described_class.new('user-123').flipper_id).to eq('User:user-123')
      end
    end
  end
  ```

  ```ruby
  # spec/models/flipper/anonymous_actor_spec.rb
  RSpec.describe Flipper::AnonymousActor do
    describe '#flipper_id' do
      it 'returns a namespaced anonymous identifier' do
        expect(described_class.new('abc-uuid').flipper_id).to eq('Anonymous:abc-uuid')
      end
    end
  end
  ```

- [ ] **Step 2: Run to verify they fail**

  ```bash
  bundle exec rspec spec/models/flipper/ --format documentation
  ```

  Expected: `NameError: uninitialized constant Flipper::UserActor`

- [ ] **Step 3: Implement the actor classes**

  ```ruby
  # app/models/flipper/user_actor.rb
  module Flipper
    class UserActor
      def initialize(user_id)
        @user_id = user_id
      end

      def flipper_id
        "User:#{@user_id}"
      end
    end
  end
  ```

  ```ruby
  # app/models/flipper/anonymous_actor.rb
  module Flipper
    class AnonymousActor
      def initialize(uuid)
        @uuid = uuid
      end

      def flipper_id
        "Anonymous:#{@uuid}"
      end
    end
  end
  ```

- [ ] **Step 4: Run tests to verify they pass**

  ```bash
  bundle exec rspec spec/models/flipper/ --format documentation
  ```

  Expected: 2 examples, 0 failures.

- [ ] **Step 5: Commit**

  ```bash
  git add app/models/flipper/ spec/models/flipper/
  git commit -m "Add UserActor and AnonymousActor for Flipper gate targeting"
  ```

---

## Task 4: Add Current model and feature_enabled? helper

**Files:**
- Create: `app/models/current.rb`
- Modify: `app/helpers/application_helper.rb`

`feature_enabled?` lives in `ApplicationHelper` so it is a genuine Rails helper — available in views naturally and properly accessible in view specs without stubbing the controller.

- [ ] **Step 1: Write failing test**

  Add a new spec file:

  ```ruby
  # spec/helpers/application_helper_spec.rb
  RSpec.describe ApplicationHelper, type: :helper do
    describe '#feature_enabled?' do
      context 'when the flag is disabled' do
        it 'returns false' do
          expect(helper.feature_enabled?(:my_feature)).to be false
        end
      end

      context 'when the flag is enabled for everyone' do
        before { Flipper.enable(:my_feature) }

        it 'returns true' do
          expect(helper.feature_enabled?(:my_feature)).to be true
        end
      end

      context 'when the flag is enabled only for a specific actor' do
        let(:actor) { Flipper::UserActor.new('user-42') }

        before { Flipper.enable_actor(:my_feature, actor) }

        it 'returns false when Current.flipper_actor is nil' do
          Current.flipper_actor = nil
          expect(helper.feature_enabled?(:my_feature)).to be false
        end

        it 'returns true when Current.flipper_actor matches' do
          Current.flipper_actor = actor
          expect(helper.feature_enabled?(:my_feature)).to be true
        end
      end
    end
  end
  ```

- [ ] **Step 2: Run to verify it fails**

  ```bash
  bundle exec rspec spec/helpers/application_helper_spec.rb --format documentation
  ```

  Expected: `NameError: uninitialized constant Current`

- [ ] **Step 3: Create the Current model**

  ```ruby
  # app/models/current.rb
  class Current < ActiveSupport::CurrentAttributes
    attribute :flipper_actor
  end
  ```

- [ ] **Step 4: Add feature_enabled? to ApplicationHelper**

  Open `app/helpers/application_helper.rb` and add inside the module body:

  ```ruby
  def feature_enabled?(flag)
    Flipper.enabled?(flag.to_sym, Current.flipper_actor)
  end
  ```

- [ ] **Step 5: Run tests to verify they pass**

  ```bash
  bundle exec rspec spec/helpers/application_helper_spec.rb --format documentation
  ```

  Expected: 4 examples, 0 failures.

- [ ] **Step 6: Commit**

  ```bash
  git add app/models/current.rb app/helpers/application_helper.rb spec/helpers/application_helper_spec.rb
  git commit -m "Add feature_enabled? helper backed by Flipper and Current.flipper_actor"
  ```

---

## Task 5: Add actor resolution to ApplicationController

**Files:**
- Modify: `app/controllers/application_controller.rb`

This task wires up `Current.flipper_actor` and the anonymous UUID cookie. `authenticated?` and `current_user_id` are derived from the existing JWT cookie mechanism used by `Myott::MyottController` — the id_token cookie is read and decoded without signature verification purely to extract a stable user identifier for Flipper targeting. Security of authenticated routes remains the responsibility of `Myott::MyottController`.

- [ ] **Step 1: Write failing tests**

  ```ruby
  # spec/controllers/application_controller_spec.rb
  RSpec.describe ApplicationController, type: :controller do
    controller do
      def index
        head :ok
      end
    end

    before { routes.draw { get 'anonymous' => 'anonymous#index' } }

    describe '#current_flipper_actor' do
      context 'when no JWT cookie is present' do
        it 'returns an AnonymousActor' do
          get :index
          expect(controller.send(:current_flipper_actor)).to be_a(Flipper::AnonymousActor)
        end

        it 'sets the flipper_anonymous_id cookie' do
          get :index
          expect(cookies[:flipper_anonymous_id]).to be_present
        end

        it 'uses the same UUID on subsequent requests' do
          get :index
          first_uuid = cookies[:flipper_anonymous_id]
          get :index
          expect(cookies[:flipper_anonymous_id]).to eq(first_uuid)
        end
      end
    end

    describe 'Current.flipper_actor' do
      it 'is set before action runs' do
        get :index
        expect(Current.flipper_actor).to be_a(Flipper::AnonymousActor)
      end
    end
  end
  ```

- [ ] **Step 2: Run to verify they fail**

  ```bash
  bundle exec rspec spec/controllers/application_controller_spec.rb --format documentation
  ```

  Expected: failures referencing undefined `current_flipper_actor`.

- [ ] **Step 3: Add actor resolution to ApplicationController**

  Open `app/controllers/application_controller.rb`. Add to the `before_action` list at the top:

  ```ruby
  before_action :set_current_flipper_actor
  ```

  Add these private methods:

  ```ruby
  def set_current_flipper_actor
    Current.flipper_actor = current_flipper_actor
  end

  def current_flipper_actor
    if authenticated?
      Flipper::UserActor.new(current_user_id)
    else
      Flipper::AnonymousActor.new(anonymous_flipper_id)
    end
  end

  def authenticated?
    cookies[TradeTariffFrontend.id_token_cookie_name].present?
  end

  def current_user_id
    return nil unless authenticated?

    token = cookies[TradeTariffFrontend.id_token_cookie_name]
    payload, = JWT.decode(token, nil, false)
    payload['email'] || payload['sub']
  rescue JWT::DecodeError
    nil
  end

  def anonymous_flipper_id
    return cookies[:flipper_anonymous_id] if cookies[:flipper_anonymous_id].present?

    uuid = SecureRandom.uuid
    cookies[:flipper_anonymous_id] = {
      value: uuid,
      expires: 1.year.from_now,
      httponly: true,
    }
    uuid
  end
  ```

- [ ] **Step 4: Run tests to verify they pass**

  ```bash
  bundle exec rspec spec/controllers/application_controller_spec.rb --format documentation
  ```

  Expected: all examples pass.

- [ ] **Step 5: Run the full suite to check for regressions**

  ```bash
  bundle exec rspec --format progress
  ```

  Expected: no new failures.

- [ ] **Step 6: Commit**

  ```bash
  git add app/controllers/application_controller.rb spec/controllers/application_controller_spec.rb
  git commit -m "Add Flipper actor resolution and anonymous UUID cookie to ApplicationController"
  ```

---

## Task 6: Add anonymous-to-authenticated migration

**Files:**
- Modify: `app/controllers/application_controller.rb`
- Modify: `spec/controllers/application_controller_spec.rb`

When a request is authenticated and an anonymous UUID cookie is present, copy the anonymous actor's opt-ins to the user actor then clear the cookie. This runs once per browser; afterwards the cookie is gone.

- [ ] **Step 1: Add failing tests**

  Append to `spec/controllers/application_controller_spec.rb`:

  ```ruby
  describe '#migrate_anonymous_flipper_actor' do
    let(:anonymous_uuid) { 'anon-uuid-999' }
    let(:user_id)        { 'user@example.com' }
    let(:anonymous_actor) { Flipper::AnonymousActor.new(anonymous_uuid) }
    let(:user_actor)      { Flipper::UserActor.new(user_id) }

    before do
      cookies[:flipper_anonymous_id] = anonymous_uuid
      allow(controller).to receive(:authenticated?).and_return(true)
      allow(controller).to receive(:current_user_id).and_return(user_id)
    end

    context 'when the anonymous actor has opted into a feature' do
      before { Flipper.enable_actor(:some_feature, anonymous_actor) }

      it 'enables the feature for the user actor' do
        get :index
        expect(Flipper.enabled?(:some_feature, user_actor)).to be true
      end

      it 'clears the anonymous cookie' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to be_blank
      end
    end

    context 'when the anonymous actor has no opt-ins' do
      it 'clears the anonymous cookie' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to be_blank
      end
    end

    context 'when the user is not authenticated' do
      before { allow(controller).to receive(:authenticated?).and_return(false) }

      it 'does not clear the anonymous cookie' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to eq(anonymous_uuid)
      end
    end
  end
  ```

- [ ] **Step 2: Run to verify they fail**

  ```bash
  bundle exec rspec spec/controllers/application_controller_spec.rb -e "migrate" --format documentation
  ```

  Expected: failures (method not defined).

- [ ] **Step 3: Add before-action and implementation**

  In `app/controllers/application_controller.rb`, add `migrate_anonymous_flipper_actor` to the `before_action` list and add the private method:

  ```ruby
  before_action :migrate_anonymous_flipper_actor
  ```

  ```ruby
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

- [ ] **Step 4: Run tests**

  ```bash
  bundle exec rspec spec/controllers/application_controller_spec.rb --format documentation
  ```

  Expected: all examples pass.

- [ ] **Step 5: Commit**

  ```bash
  git add app/controllers/application_controller.rb spec/controllers/application_controller_spec.rb
  git commit -m "Migrate anonymous Flipper actor opt-ins to user actor on first authenticated request"
  ```

---

## Task 7: Configure Flipper initializer, webhook, and rack-attack

**Files:**
- Create: `config/initializers/flipper.rb`
- Modify: `config/routes.rb`
- Modify: `config/initializers/rack_attack.rb`

**Before starting:** Log in to Flipper Cloud, create your app, and note the `FLIPPER_CLOUD_TOKEN` and `FLIPPER_CLOUD_SYNC_SECRET` values. Add both to `.env.development.local` and to the staging/production environment config in Terraform/AWS.

- [ ] **Step 1: Create the Flipper initializer**

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

- [ ] **Step 2: Mount the Flipper Cloud webhook engine**

  Open `config/routes.rb` and add before the final `end`:

  ```ruby
  mount Flipper::Cloud::Engine, at: '/flipper'
  ```

  This provides the webhook endpoint at `/flipper/webhooks`. Configure Flipper Cloud to push to `https://<your-domain>/flipper/webhooks`.

- [ ] **Step 3: Exempt the webhook from rack-attack rate limiting**

  Open `config/initializers/rack_attack.rb` and add:

  ```ruby
  Rack::Attack.safelist('allow-flipper-webhooks') do |req|
    req.path == '/flipper/webhooks' && req.post?
  end
  ```

- [ ] **Step 4: Smoke test locally**

  ```bash
  bin/rails start
  ```

  Expected: server starts without error. Check logs for any Flipper connection errors. If `FLIPPER_CLOUD_TOKEN` is not yet set, temporarily set it in `.env.development.local` to test.

- [ ] **Step 5: Commit**

  ```bash
  git add config/initializers/flipper.rb config/routes.rb config/initializers/rack_attack.rb
  git commit -m "Configure Flipper Cloud with Redis local adapter and webhook endpoint"
  ```

---

## Task 8: Implement FeatureOptInsController

**Files:**
- Create: `app/controllers/feature_opt_ins_controller.rb`
- Modify: `config/routes.rb`
- Create: `spec/requests/feature_opt_ins_controller_spec.rb`

The controller validates the flag name against an explicit allowlist to prevent arbitrary actor-enables.

- [ ] **Step 1: Write failing tests**

  ```ruby
  # spec/requests/feature_opt_ins_controller_spec.rb
  RSpec.describe FeatureOptInsController, type: :request do
    let(:anonymous_uuid) { 'test-uuid-123' }

    before do
      cookies[:flipper_anonymous_id] = anonymous_uuid
      stub_const('FeatureOptInsController::MANAGEABLE_FEATURES', %i[test_flag])
    end

    describe 'POST /feature_opt_ins' do
      context 'with a known opt-in-able flag' do
        it 'enables the actor for the flag and redirects' do
          post feature_opt_ins_path, params: { feature: 'test_flag' }

          actor = Flipper::AnonymousActor.new(anonymous_uuid)
          expect(Flipper.enabled?(:test_flag, actor)).to be true
          expect(response).to redirect_to(root_path)
        end
      end

      context 'with an unknown flag' do
        it 'returns 403' do
          post feature_opt_ins_path, params: { feature: 'nonexistent_flag' }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    describe 'DELETE /feature_opt_ins' do
      context 'with a known opt-in-able flag' do
        before do
          actor = Flipper::AnonymousActor.new(anonymous_uuid)
          Flipper.enable_actor(:test_flag, actor)
        end

        it 'disables the actor for the flag and redirects' do
          delete feature_opt_in_path('test_flag')

          actor = Flipper::AnonymousActor.new(anonymous_uuid)
          expect(Flipper.enabled?(:test_flag, actor)).to be false
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
  ```

- [ ] **Step 2: Run to verify they fail**

  ```bash
  bundle exec rspec spec/requests/feature_opt_ins_controller_spec.rb --format documentation
  ```

  Expected: routing error or uninitialized constant.

- [ ] **Step 3: Add routes**

  Open `config/routes.rb` and add:

  ```ruby
  resources :feature_opt_ins, only: %i[create destroy]
  ```

- [ ] **Step 4: Implement the controller**

  ```ruby
  # app/controllers/feature_opt_ins_controller.rb
  class FeatureOptInsController < ApplicationController
    MANAGEABLE_FEATURES = %i[].freeze

    def create
      flag = params[:feature].to_sym
      return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

      Flipper.enable_actor(flag, current_flipper_actor)
      redirect_back fallback_location: root_path
    end

    def destroy
      flag = params[:id].to_sym
      return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

      Flipper.disable_actor(flag, current_flipper_actor)
      redirect_back fallback_location: root_path
    end
  end
  ```

  Note: `MANAGEABLE_FEATURES` starts empty. Add flag symbols to it as features are made opt-in-able, e.g. `MANAGEABLE_FEATURES = %i[interactive_search].freeze`. Tests use `stub_const` to override it without touching the frozen array.

- [ ] **Step 5: Run tests**

  ```bash
  bundle exec rspec spec/requests/feature_opt_ins_controller_spec.rb --format documentation
  ```

  Expected: all examples pass.

- [ ] **Step 6: Commit**

  ```bash
  git add app/controllers/feature_opt_ins_controller.rb config/routes.rb spec/requests/feature_opt_ins_controller_spec.rb
  git commit -m "Add FeatureOptInsController for per-actor flag opt-in and opt-out"
  ```

---

## Task 9: Migrate existing call sites and remove old flag methods

**Files:**
- Modify: `app/models/search.rb`
- Modify: `app/controllers/find_commodities_controller.rb`
- Modify: `app/controllers/application_controller.rb`
- Modify: `app/controllers/search_controller.rb`
- Modify: `app/controllers/green_lanes/category_assessments_controller.rb`
- Modify: `app/controllers/concerns/interactive_searchable.rb`
- Modify: `app/views/shared/_stw_link.html.erb`
- Modify: `app/views/shared/webchat_message/_not_found.html.erb`
- Modify: `app/views/shared/webchat_message/_footer.html.erb`
- Modify: `app/views/shared/webchat_message/_help.html.erb`
- Modify: `app/views/search/_interactive_support_links.html.erb`
- Modify: `app/views/search/_interactive_error_sidebar.html.erb`
- Modify: `app/views/search/_interactive_results_sidebar.html.erb`
- Modify: `app/views/measures/_measures.html.erb`
- Modify: `lib/trade_tariff_frontend.rb`
- Modify: Multiple spec files (listed below)

**Before starting:** Create all six flags in Flipper Cloud and set each to match its current production state (check the current ENV var values in your production environment config):

| Flipper flag | Set to match ENV var |
|---|---|
| `:green_lanes` | `GREEN_LANES_ENABLED` |
| `:roo_wizard` | `ROO_WIZARD` |
| `:interactive_search` | *(was `!production? && !xi?`)* — set to `false` initially |
| `:single_trade_window` | `STW_ENABLED` |
| `:webchat` | `WEBCHAT_URL` present → `true` |
| `:welsh` | `WELSH` |

- [ ] **Step 1: Update app call sites**

  Make the following replacements. In controllers and concerns, `feature_enabled?` is available directly. In models, use `Flipper.enabled?(:flag, Current.flipper_actor)` since the helper is not available there.

  **`app/controllers/application_controller.rb`** — find and replace:
  ```ruby
  # Before (line ~129):
  if TradeTariffFrontend.interactive_search_enabled?
  # After:
  if feature_enabled?(:interactive_search)

  # Before (line ~139):
  unless TradeTariffFrontend.green_lanes_enabled?
  # After:
  unless feature_enabled?(:green_lanes)
  ```

  **`app/controllers/find_commodities_controller.rb`** — find and replace:
  ```ruby
  # Before:
  render :show_interactive if TradeTariffFrontend.interactive_search_enabled?
  # After:
  render :show_interactive if feature_enabled?(:interactive_search)
  ```

  **`app/controllers/search_controller.rb`** — find and replace:
  ```ruby
  # Before:
  return suggestions unless TradeTariffFrontend.interactive_search_enabled?
  # After:
  return suggestions unless feature_enabled?(:interactive_search)
  ```

  **`app/controllers/green_lanes/category_assessments_controller.rb`** — find and replace:
  ```ruby
  # Before:
  raise TradeTariffFrontend::FeatureUnavailable unless TradeTariffFrontend.green_lanes_enabled?
  # After:
  raise TradeTariffFrontend::FeatureUnavailable unless feature_enabled?(:green_lanes)
  ```

  **`app/controllers/concerns/interactive_searchable.rb`** — find and replace:
  ```ruby
  # Before:
  @search.interactive_search && TradeTariffFrontend.interactive_search_enabled?
  # After:
  @search.interactive_search && feature_enabled?(:interactive_search)
  ```

  **`app/models/search.rb`** — find and replace (model context, no helper available):
  ```ruby
  # Before:
  if interactive_search && TradeTariffFrontend.interactive_search_enabled?
  # After:
  if interactive_search && Flipper.enabled?(:interactive_search, Current.flipper_actor)
  ```

- [ ] **Step 2: Update view call sites**

  **`app/views/shared/_stw_link.html.erb`**:
  ```erb
  <%# Before: %>
  <% if TradeTariffFrontend.single_trade_window_linking_enabled? %>
  <%# After: %>
  <% if feature_enabled?(:single_trade_window) %>
  ```

  **`app/views/shared/webchat_message/_not_found.html.erb`**:
  ```erb
  <%# Before: %>
  <% if TradeTariffFrontend.webchat_enabled? %>
  <%# After: %>
  <% if feature_enabled?(:webchat) %>
  ```

  **`app/views/shared/webchat_message/_footer.html.erb`**:
  ```erb
  <%# Before: %>
  <% if TradeTariffFrontend.webchat_enabled? %>
  <%# After: %>
  <% if feature_enabled?(:webchat) %>
  ```

  **`app/views/shared/webchat_message/_help.html.erb`**:
  ```erb
  <%# Before: %>
  <% if TradeTariffFrontend.webchat_enabled? %>
  <%# After: %>
  <% if feature_enabled?(:webchat) %>
  ```

  **`app/views/search/_interactive_support_links.html.erb`**:
  ```erb
  <%# Before: %>
  <% if TradeTariffFrontend.webchat_enabled? %>
  <%# After: %>
  <% if feature_enabled?(:webchat) %>
  ```

  **`app/views/search/_interactive_error_sidebar.html.erb`**:
  ```erb
  <%# Before: %>
  <% if TradeTariffFrontend.webchat_enabled? %>
  <%# After: %>
  <% if feature_enabled?(:webchat) %>
  ```

  **`app/views/search/_interactive_results_sidebar.html.erb`**:
  ```erb
  <%# Before: %>
  <% if TradeTariffFrontend.webchat_enabled? %>
  <%# After: %>
  <% if feature_enabled?(:webchat) %>
  ```

  **`app/views/measures/_measures.html.erb`** (line ~68):
  ```erb
  <%# Before: %>
  <%= render (TradeTariffFrontend.roo_wizard? ? 'rules_of_origin/tab_' + tariff_tab : 'rules_of_origin/legacy/tab'),
  <%# After: %>
  <%= render (feature_enabled?(:roo_wizard) ? 'rules_of_origin/tab_' + tariff_tab : 'rules_of_origin/legacy/tab'),
  ```

- [ ] **Step 3: Update test stubs**

  Replace `allow(TradeTariffFrontend).to receive` stubs with `Flipper.enable` calls. Each file and location:

  **`spec/models/search_spec.rb`** — replace all 5 occurrences:
  ```ruby
  # Before:
  allow(TradeTariffFrontend).to receive(:interactive_search_enabled?).and_return(true)
  # After:
  Flipper.enable(:interactive_search)

  # Before:
  allow(TradeTariffFrontend).to receive(:interactive_search_enabled?).and_return(false)
  # After:
  # (remove — flags default to false in test support, no line needed)
  ```

  **`spec/requests/green_lanes/eligibilities_controller_spec.rb`** (line 7):
  ```ruby
  # Before:
  allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return true
  # After:
  before { Flipper.enable(:green_lanes) }
  ```

  **`spec/requests/green_lanes/category_assessments_controller_spec.rb`** (lines 7, 96):
  ```ruby
  # Before (line 7):
  allow(TradeTariffFrontend).to receive_messages(green_lanes_enabled?: true, green_lanes_api_token: '')
  # After:
  Flipper.enable(:green_lanes)
  allow(TradeTariffFrontend).to receive(:green_lanes_api_token).and_return('')

  # Before (line 96):
  allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return false
  # After:
  # (remove — flags default to false)
  ```

  **`spec/requests/green_lanes/eligibility_results_controller_spec.rb`** (line 7):
  ```ruby
  # Before:
  allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return true
  # After:
  before { Flipper.enable(:green_lanes) }
  ```

  **`spec/requests/green_lanes/results_controller_spec.rb`** (line 7):
  ```ruby
  # Before:
  allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return true
  # After:
  before { Flipper.enable(:green_lanes) }
  ```

  **`spec/controllers/search_controller_search_spec.rb`** (line 308):
  ```ruby
  # Before:
  allow(TradeTariffFrontend).to receive(:interactive_search_enabled?).and_return(true)
  # After:
  Flipper.enable(:interactive_search)
  ```

  **`spec/views/shared/_stw_link.html.erb_spec.rb`** (line 9):
  ```ruby
  # Before:
  allow(TradeTariffFrontend).to receive(:single_trade_window_linking_enabled?).and_return(single_trade_window_linking_enabled?)
  # After:
  Flipper.enable(:single_trade_window) if single_trade_window_linking_enabled?
  ```

  **`spec/views/search/_interactive_results_content.html.erb_spec.rb`** (lines 142, 152):
  ```ruby
  # Before (line 142):
  before { allow(TradeTariffFrontend).to receive(:webchat_enabled?).and_return(true) }
  # After:
  before { Flipper.enable(:webchat) }

  # Before (line 152):
  before { allow(TradeTariffFrontend).to receive(:webchat_enabled?).and_return(false) }
  # After:
  # (remove — flags default to false)
  ```

  **`spec/views/search/_interactive_unknown_results_content.html.erb_spec.rb`** (lines 50, 59):
  ```ruby
  # Before (line 50):
  before { allow(TradeTariffFrontend).to receive(:webchat_enabled?).and_return(true) }
  # After:
  before { Flipper.enable(:webchat) }

  # Before (line 59):
  before { allow(TradeTariffFrontend).to receive(:webchat_enabled?).and_return(false) }
  # After:
  # (remove — flags default to false)
  ```

  **`spec/views/measures/_measures.html.erb_spec.rb`** (lines 106, 133, 141):
  ```ruby
  # Before (line 106):
  before { allow(TradeTariffFrontend).to receive(:roo_wizard?).and_return false }
  # After:
  # (remove — flags default to false)

  # Before (line 133):
  before { allow(TradeTariffFrontend).to receive(:roo_wizard?).and_return true }
  # After:
  before { Flipper.enable(:roo_wizard) }

  # Before (line 141):
  before { allow(TradeTariffFrontend).to receive(:roo_wizard?).and_return false }
  # After:
  # (remove — flags default to false)
  ```

- [ ] **Step 4: Remove old flag methods from TradeTariffFrontend**

  Open `lib/trade_tariff_frontend.rb` and delete these methods entirely:

  ```ruby
  # DELETE these methods:
  def green_lanes_enabled?
  def interactive_search_enabled?
  def roo_wizard?
  def single_trade_window_linking_enabled?
  def webchat_enabled?
  def webchat_url           # only if not used elsewhere — check first
  def welsh?
  ```

  Also remove the associated ENV var reads where they only served the flag methods (`STW_ENABLED`, `GREEN_LANES_ENABLED`, `ROO_WIZARD`, `WELSH`, `WEBCHAT_URL`). Leave any other usages of those ENV vars intact if they exist.

- [ ] **Step 5: Run the full test suite**

  ```bash
  bundle exec rspec --format progress
  ```

  Expected: no failures. If there are failures, they will identify any call sites missed in steps 1-3. Fix them before continuing.

- [ ] **Step 6: Commit**

  ```bash
  git add -p
  git commit -m "Migrate all feature flag call sites from TradeTariffFrontend to feature_enabled?"
  ```

---

## Task 10: Remove ENV vars from infrastructure config

**This task is done outside the Rails codebase.** After the deployment in Task 9 is stable:

- [ ] Remove `GREEN_LANES_ENABLED`, `ROO_WIZARD`, `STW_ENABLED`, `WELSH`, `WEBCHAT_URL` from the Terraform environment config in `terraform/` (or wherever environment variables are managed for staging and production)
- [ ] Verify in staging that all flags continue to behave as expected with the ENV vars absent (Flipper Cloud is now the sole source of truth)
- [ ] Commit the Terraform change
