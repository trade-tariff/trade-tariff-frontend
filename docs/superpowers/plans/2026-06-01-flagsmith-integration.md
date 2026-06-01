# FlagSmith Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the existing env-var feature flags (`GREEN_LANES_ENABLED`, `WEBCHAT_URL`, etc.) with self-hosted FlagSmith, adding per-identity flag evaluation and opt-in infrastructure.

**Architecture:** The `flagsmith` gem's `Flagsmith::Client` handles all flag evaluation via `get_identity_flags(identifier)`. A singleton `FlagsmithClient` wrapper holds the SDK client and exposes Admin API mutation methods (Faraday) for per-identity flag overrides. `Current.flagsmith_identity` carries the resolved identity (anonymous UUID or JWT user) for the request lifetime, and `feature_enabled?(:flag)` in `ApplicationHelper` is the single call site for all flag checks.

**Tech Stack:** `flagsmith` gem 4.3.0, Faraday (already in Gemfile), `ActiveSupport::CurrentAttributes`, JWT (already in Gemfile), RSpec + WebMock (already in test group).

---

## File Map

**Create:**
- `app/models/current.rb` — per-request state (identity + memoised flags)
- `app/models/flagsmith/anonymous_identity.rb` — anonymous identity (UUID cookie)
- `app/models/flagsmith/user_identity.rb` — authenticated identity (JWT claim)
- `app/services/flagsmith_client.rb` — SDK wrapper + Admin API mutations
- `app/controllers/feature_opt_ins_controller.rb` — user-facing flag opt-in
- `config/initializers/flagsmith.rb` — configure FlagsmithClient at boot
- `spec/models/current_spec.rb`
- `spec/models/flagsmith/anonymous_identity_spec.rb`
- `spec/models/flagsmith/user_identity_spec.rb`
- `spec/services/flagsmith_client_spec.rb`
- `spec/requests/feature_opt_ins_controller_spec.rb`
- `spec/support/flagsmith.rb` — in-memory test double + helpers

**Modify:**
- `Gemfile` — add `gem 'flagsmith'`
- `app/helpers/application_helper.rb` — add `feature_enabled?`, `feature_value`, `webchat_url`, `webchat_enabled?`
- `app/helpers/webchat_helper.rb` — remove `TradeTariffFrontend.webchat_url` reference
- `app/helpers/intercept_guidance_helper.rb` — remove `TradeTariffFrontend.webchat_url` reference
- `app/controllers/application_controller.rb` — add `before_action`s for identity resolution and migration; replace `TradeTariffFrontend` flag calls
- `app/controllers/concerns/interactive_searchable.rb` — replace `TradeTariffFrontend.interactive_search_enabled?`
- `app/controllers/find_commodities_controller.rb` — replace `TradeTariffFrontend.interactive_search_enabled?`
- `app/controllers/search_controller.rb` — replace `TradeTariffFrontend.interactive_search_enabled?`
- `app/models/search.rb` — replace `TradeTariffFrontend.interactive_search_enabled?`
- `app/views/search/_interactive_error_sidebar.html.erb` — replace `TradeTariffFrontend.webchat_enabled?`
- `app/views/search/_interactive_results_sidebar.html.erb` — replace `TradeTariffFrontend.webchat_enabled?`
- `app/views/search/_interactive_support_links.html.erb` — replace `TradeTariffFrontend.webchat_enabled?`
- `app/views/shared/webchat_message/_footer.html.erb` — replace `TradeTariffFrontend.webchat_enabled?`
- `app/views/shared/webchat_message/_help.html.erb` — replace `TradeTariffFrontend.webchat_enabled?`
- `app/views/shared/webchat_message/_not_found.html.erb` — replace `TradeTariffFrontend.webchat_enabled?`
- `app/views/measures/_measures.html.erb` — replace `TradeTariffFrontend.roo_wizard?`
- `app/views/shared/_stw_link.html.erb` — replace `TradeTariffFrontend.single_trade_window_linking_enabled?`
- `config/routes.rb` — add `resources :feature_opt_ins, only: %i[create destroy]`
- `lib/trade_tariff_frontend.rb` — remove the six env-var flag methods
- `config/environments/test.rb` — note: no changes needed (FlagsmithClient is replaced by test double before boot)

---

## Task 1: Add the flagsmith gem

**Files:**
- Modify: `Gemfile`

- [ ] **Step 1: Add the gem**

  In `Gemfile`, after the `gem 'jwt'` line, add:

  ```ruby
  gem 'flagsmith', '~> 4.3'
  ```

- [ ] **Step 2: Install**

  ```bash
  bundle install
  ```

  Expected: bundler resolves and installs `flagsmith 4.3.0` (plus any transitive deps).

- [ ] **Step 3: Commit**

  ```bash
  git add Gemfile Gemfile.lock
  git commit -m "Add flagsmith gem"
  ```

---

## Task 2: Implement identity structs

Two plain Ruby structs. Each produces a stable identifier string that FlagSmith uses as the identity key.

**Files:**
- Create: `app/models/flagsmith/anonymous_identity.rb`
- Create: `app/models/flagsmith/user_identity.rb`
- Create: `spec/models/flagsmith/anonymous_identity_spec.rb`
- Create: `spec/models/flagsmith/user_identity_spec.rb`

- [ ] **Step 1: Write the failing tests**

  `spec/models/flagsmith/anonymous_identity_spec.rb`:

  ```ruby
  RSpec.describe Flagsmith::AnonymousIdentity do
    subject(:identity) { described_class.new('abc-123') }

    it 'exposes the identifier string' do
      expect(identity.identifier).to eq('Anonymous:abc-123')
    end
  end
  ```

  `spec/models/flagsmith/user_identity_spec.rb`:

  ```ruby
  RSpec.describe Flagsmith::UserIdentity do
    subject(:identity) { described_class.new('neil@example.com') }

    it 'exposes the identifier string' do
      expect(identity.identifier).to eq('User:neil@example.com')
    end
  end
  ```

- [ ] **Step 2: Run to confirm they fail**

  ```bash
  bundle exec rspec spec/models/flagsmith/ --no-color
  ```

  Expected: 2 failures — `uninitialized constant Flagsmith::AnonymousIdentity` and `Flagsmith::UserIdentity`.

- [ ] **Step 3: Implement**

  `app/models/flagsmith/anonymous_identity.rb`:

  ```ruby
  module Flagsmith
    class AnonymousIdentity
      attr_reader :identifier

      def initialize(uuid)
        @identifier = "Anonymous:#{uuid}"
      end
    end
  end
  ```

  `app/models/flagsmith/user_identity.rb`:

  ```ruby
  module Flagsmith
    class UserIdentity
      attr_reader :identifier

      def initialize(user_id)
        @identifier = "User:#{user_id}"
      end
    end
  end
  ```

- [ ] **Step 4: Run to confirm they pass**

  ```bash
  bundle exec rspec spec/models/flagsmith/ --no-color
  ```

  Expected: 2 examples, 0 failures.

- [ ] **Step 5: Commit**

  ```bash
  git add app/models/flagsmith/ spec/models/flagsmith/
  git commit -m "Add Flagsmith identity structs"
  ```

---

## Task 3: Current model and test support

`Current` is a Rails `CurrentAttributes` object — it resets automatically between requests. It holds the resolved identity and the memoised flags for the request. The test support wires in an in-memory double before any specs run, so all subsequent tasks can test against it without hitting the real FlagSmith API.

**Files:**
- Create: `app/models/current.rb`
- Create: `spec/models/current_spec.rb`
- Create: `spec/support/flagsmith.rb`

- [ ] **Step 1: Write the failing test**

  `spec/models/current_spec.rb`:

  ```ruby
  RSpec.describe Current do
    it 'can store and retrieve a flagsmith identity' do
      identity = Flagsmith::UserIdentity.new('neil@example.com')
      Current.flagsmith_identity = identity
      expect(Current.flagsmith_identity).to eq(identity)
    end

    it 'can store and retrieve memoised flags' do
      flags = double(:flags)
      Current.flagsmith_flags = flags
      expect(Current.flagsmith_flags).to eq(flags)
    end

    it 'resets between examples' do
      expect(Current.flagsmith_identity).to be_nil
      expect(Current.flagsmith_flags).to be_nil
    end
  end
  ```

- [ ] **Step 2: Run to confirm it fails**

  ```bash
  bundle exec rspec spec/models/current_spec.rb --no-color
  ```

  Expected: `uninitialized constant Current`.

- [ ] **Step 3: Implement Current**

  `app/models/current.rb`:

  ```ruby
  class Current < ActiveSupport::CurrentAttributes
    # The resolved Flagsmith identity for the current request.
    # Set by ApplicationController#set_current_flagsmith_identity.
    attribute :flagsmith_identity

    # The memoised flags collection returned by FlagsmithClient#get_flags_for.
    # Populated on first call to feature_enabled? and reused for the request lifetime.
    attribute :flagsmith_flags
  end
  ```

- [ ] **Step 4: Run to confirm it passes**

  ```bash
  bundle exec rspec spec/models/current_spec.rb --no-color
  ```

  Expected: 3 examples, 0 failures.

- [ ] **Step 5: Write test support**

  `spec/support/flagsmith.rb`:

  ```ruby
  # In-memory stand-in for the real FlagsmithClient. Holds a simple hash of
  # flag_name => enabled. All flags default to false. Shared across threads
  # (it is a constant, not thread-local), so Puma server threads in JS tests
  # see the same state as the test thread.
  class TestFlagsmithClient
    class TestFlags
      def initialize(flags)
        @flags = flags
      end

      def is_feature_enabled(flag_name)
        @flags.fetch(flag_name.to_s, false)
      end

      def get_feature_value(flag_name)
        nil
      end
    end

    def initialize
      @flags = {}
    end

    def set_flag(flag, enabled)
      @flags[flag.to_s] = enabled
    end

    def reset!
      @flags = {}
    end

    # FlagsmithClient interface — evaluation
    def get_flags_for(_identity)
      TestFlags.new(@flags)
    end

    # FlagsmithClient interface — Admin API mutations (no-ops in tests)
    def enable_for_identity(_flag, _identity)
      true
    end

    def disable_for_identity(_flag, _identity)
      true
    end

    def get_identity_overrides(_identifier)
      []
    end

    def delete_identity(_identifier)
      true
    end
  end

  TEST_FLAGSMITH_CLIENT = TestFlagsmithClient.new

  RSpec.configure do |config|
    config.before(:suite) do
      # Replace the real FlagsmithClient singleton with the test double before
      # any examples run. FlagsmithClient.instance= is defined in Task 4.
      # The guard means this file can be loaded safely before Task 4 is complete.
      next unless defined?(FlagsmithClient)

      FlagsmithClient.instance = TEST_FLAGSMITH_CLIENT
    end

    config.before do
      TEST_FLAGSMITH_CLIENT.reset!
      Current.reset
    end
  end

  # Test helpers — product-agnostic names so specs don't mention FlagSmith directly.
  def enable_feature(flag)
    TEST_FLAGSMITH_CLIENT.set_flag(flag, true)
  end

  def disable_feature(flag)
    TEST_FLAGSMITH_CLIENT.set_flag(flag, false)
  end
  ```

  Add the require to `spec/spec_helper.rb` — the `Dir[Rails.root.join('spec/support/**/*.rb')]` glob already loads it automatically, so no change needed there.

- [ ] **Step 6: Commit**

  ```bash
  git add app/models/current.rb spec/models/current_spec.rb spec/support/flagsmith.rb
  git commit -m "Add Current model and Flagsmith test support"
  ```

---

## Task 4: FlagsmithClient — evaluation

The core wrapper around `Flagsmith::Client`. Exposes `get_flags_for(identity)` which returns the SDK flags collection. Has a class-level `instance=` setter so tests can swap in the double.

**Files:**
- Create: `app/services/flagsmith_client.rb`
- Create: `spec/services/flagsmith_client_spec.rb`

- [ ] **Step 1: Write the failing tests**

  `spec/services/flagsmith_client_spec.rb`:

  ```ruby
  RSpec.describe FlagsmithClient do
    describe '.instance' do
      it 'returns the singleton' do
        expect(described_class.instance).to be_a(described_class)
      end

      it 'returns the same object on repeated calls' do
        expect(described_class.instance).to equal(described_class.instance)
      end
    end

    describe '.instance=' do
      it 'replaces the singleton' do
        replacement = double(:client)
        described_class.instance = replacement
        expect(described_class.instance).to equal(replacement)
      end
    end

    describe '#get_flags_for' do
      subject(:client) do
        described_class.new(
          environment_key: 'test-env-key',
          api_url: 'https://flagsmith.example.com/api/v1/',
          admin_api_key: 'test-admin-key',
        )
      end

      let(:identity) { Flagsmith::UserIdentity.new('neil@example.com') }

      before do
        stub_request(:get, 'https://flagsmith.example.com/api/v1/identities/')
          .with(
            query: { identifier: 'User:neil@example.com' },
            headers: { 'X-Environment-Key' => 'test-env-key' },
          )
          .to_return(
            status: 200,
            body: {
              'flags' => [
                { 'feature' => { 'name' => 'green_lanes', 'id' => 1 }, 'enabled' => true, 'feature_state_value' => nil },
              ],
              'traits' => [],
            }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )
      end

      it 'returns a flags collection' do
        flags = client.get_flags_for(identity)
        expect(flags.is_feature_enabled('green_lanes')).to be true
      end

      it 'returns false for unknown flags' do
        flags = client.get_flags_for(identity)
        expect(flags.is_feature_enabled('unknown_flag')).to be false
      end
    end
  end
  ```

- [ ] **Step 2: Run to confirm they fail**

  ```bash
  bundle exec rspec spec/services/flagsmith_client_spec.rb --no-color
  ```

  Expected: failures — `uninitialized constant FlagsmithClient`.

- [ ] **Step 3: Implement**

  `app/services/flagsmith_client.rb`:

  ```ruby
  # Singleton wrapper around the FlagSmith SDK client.
  #
  # Evaluation (get_flags_for) uses the SDK environment key.
  # Mutations (enable_for_identity, disable_for_identity, etc.) use the
  # Admin API key via Faraday.
  #
  # In the test environment, FlagsmithClient.instance is replaced with a
  # TestFlagsmithClient double before any examples run (see spec/support/flagsmith.rb).
  class FlagsmithClient
    class << self
      def instance
        @instance ||= new(
          environment_key: ENV.fetch('FLAGSMITH_ENVIRONMENT_KEY', nil),
          api_url: ENV.fetch('FLAGSMITH_API_URL', nil),
          admin_api_key: ENV.fetch('FLAGSMITH_ADMIN_API_KEY', nil),
        )
      end

      def instance=(client)
        @instance = client
      end
    end

    def initialize(environment_key:, api_url:, admin_api_key:)
      @environment_key = environment_key
      @api_url = api_url.to_s.delete_suffix('/')
      @admin_api_key = admin_api_key
      @sdk_client = Flagsmith::Client.new(
        environment_key: @environment_key,
        api_url: "#{@api_url}/",
      )
    end

    # Returns a Flagsmith::Flags::Collection for the given identity.
    # Call is_feature_enabled('flag_name') or get_feature_value('flag_name') on the result.
    def get_flags_for(identity)
      @sdk_client.get_identity_flags(identity.identifier)
    end

    # Sets a per-identity flag override to enabled via the Admin API.
    def enable_for_identity(flag, identity)
      set_identity_flag_state(flag.to_s, identity, enabled: true)
    end

    # Sets a per-identity flag override to disabled via the Admin API.
    def disable_for_identity(flag, identity)
      set_identity_flag_state(flag.to_s, identity, enabled: false)
    end

    # Returns an array of flag names that are overridden to enabled for the given identifier.
    # Used by the anonymous→authenticated migration to know which flags to copy.
    def get_identity_overrides(identifier)
      identity_pk = fetch_or_create_identity_pk(identifier)
      resp = admin_connection.get(
        "environments/#{@environment_key}/identities/#{identity_pk}/featurestates/"
      )
      resp.body.fetch('results', [])
          .select { |fs| fs['enabled'] }
          .map { |fs| fs.dig('feature', 'name') }
    end

    # Deletes an identity record from FlagSmith.
    # Called during anonymous→authenticated migration to clean up the anonymous identity.
    def delete_identity(identifier)
      results = admin_connection.get(
        "environments/#{@environment_key}/identities/",
        { q: identifier },
      ).body.fetch('results', [])
      return if results.empty?

      admin_connection.delete(
        "environments/#{@environment_key}/identities/#{results.first['id']}/"
      )
    end

    private

    # Two-step Admin API write: find (or create) the identity's numeric pk, then
    # either patch an existing feature state or create a new one for that identity.
    def set_identity_flag_state(flag_name, identity, enabled:)
      identity_pk = fetch_or_create_identity_pk(identity.identifier)
      write_feature_state(identity_pk, flag_name, enabled:)
    end

    def fetch_or_create_identity_pk(identifier)
      results = admin_connection.get(
        "environments/#{@environment_key}/identities/",
        { q: identifier },
      ).body.fetch('results', [])

      return results.first['id'] if results.any?

      admin_connection.post(
        "environments/#{@environment_key}/identities/"
      ) { |req| req.body = { identifier: }.to_json }.body['id']
    end

    def write_feature_state(identity_pk, flag_name, enabled:)
      featurestates_url = "environments/#{@environment_key}/identities/#{identity_pk}/featurestates/"
      existing_resp = admin_connection.get(featurestates_url)
      existing = existing_resp.body.fetch('results', []).find do |fs|
        fs.dig('feature', 'name') == flag_name
      end

      if existing
        admin_connection.patch("#{featurestates_url}#{existing['id']}/") do |req|
          req.body = { enabled: }.to_json
        end
      else
        feature_id = fetch_feature_id(flag_name)
        admin_connection.post(featurestates_url) do |req|
          req.body = { feature: feature_id, enabled: }.to_json
        end
      end
    end

    def fetch_feature_id(flag_name)
      admin_connection
        .get("features/featurestates/", { environment: @environment_key, feature__name: flag_name })
        .body.fetch('results', []).first&.dig('feature')
    end

    def admin_connection
      @admin_connection ||= Faraday.new(url: "#{@api_url}/") do |conn|
        conn.request :json
        conn.response :json
        conn.headers['Authorization'] = "Token #{@admin_api_key}"
        conn.adapter :net_http
      end
    end
  end
  ```

- [ ] **Step 4: Run to confirm the evaluation tests pass**

  ```bash
  bundle exec rspec spec/services/flagsmith_client_spec.rb --no-color
  ```

  Expected: 4 examples, 0 failures.

- [ ] **Step 5: Commit**

  ```bash
  git add app/services/flagsmith_client.rb spec/services/flagsmith_client_spec.rb
  git commit -m "Add FlagsmithClient evaluation wrapper"
  ```

---

## Task 5: FlagsmithClient — Admin API mutations

Add specs for the mutation methods (`enable_for_identity`, `disable_for_identity`, `get_identity_overrides`, `delete_identity`). These use WebMock to stub the multi-step Admin API calls.

**Files:**
- Modify: `spec/services/flagsmith_client_spec.rb`

- [ ] **Step 1: Add the mutation specs**

  Add this block inside `RSpec.describe FlagsmithClient` in `spec/services/flagsmith_client_spec.rb`, after the `#get_flags_for` block:

  ```ruby
  describe 'Admin API mutations' do
    subject(:client) do
      described_class.new(
        environment_key: 'test-env-key',
        api_url: 'https://flagsmith.example.com/api/v1/',
        admin_api_key: 'test-admin-key',
      )
    end

    let(:identity) { Flagsmith::UserIdentity.new('neil@example.com') }
    let(:identity_pk) { 42 }
    let(:admin_headers) { { 'Authorization' => 'Token test-admin-key' } }
    let(:base_url) { 'https://flagsmith.example.com/api/v1/environments/test-env-key/identities' }

    before do
      # Stub identity lookup (used by enable/disable/get_overrides/delete)
      stub_request(:get, "#{base_url}/")
        .with(query: { q: 'User:neil@example.com' }, headers: admin_headers)
        .to_return(
          status: 200,
          body: { 'results' => [{ 'id' => identity_pk, 'identifier' => 'User:neil@example.com' }] }.to_json,
          headers: { 'Content-Type' => 'application/json' },
        )
    end

    describe '#enable_for_identity' do
      before do
        # No existing feature state for this identity
        stub_request(:get, "#{base_url}/#{identity_pk}/featurestates/")
          .with(headers: admin_headers)
          .to_return(
            status: 200,
            body: { 'results' => [] }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        # Look up feature id by name
        stub_request(:get, 'https://flagsmith.example.com/api/v1/features/featurestates/')
          .with(
            query: { environment: 'test-env-key', feature__name: 'green_lanes' },
            headers: admin_headers,
          )
          .to_return(
            status: 200,
            body: { 'results' => [{ 'feature' => 7 }] }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        stub_request(:post, "#{base_url}/#{identity_pk}/featurestates/")
          .with(
            body: { 'feature' => 7, 'enabled' => true }.to_json,
            headers: admin_headers,
          )
          .to_return(status: 201, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      it 'POSTs a new enabled feature state for the identity' do
        client.enable_for_identity(:green_lanes, identity)
        expect(WebMock).to have_requested(:post, "#{base_url}/#{identity_pk}/featurestates/")
          .with(body: { 'feature' => 7, 'enabled' => true }.to_json)
      end
    end

    describe '#disable_for_identity' do
      before do
        # Existing feature state to patch
        stub_request(:get, "#{base_url}/#{identity_pk}/featurestates/")
          .with(headers: admin_headers)
          .to_return(
            status: 200,
            body: {
              'results' => [
                { 'id' => 99, 'feature' => { 'name' => 'green_lanes' }, 'enabled' => true },
              ],
            }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        stub_request(:patch, "#{base_url}/#{identity_pk}/featurestates/99/")
          .with(
            body: { 'enabled' => false }.to_json,
            headers: admin_headers,
          )
          .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      it 'PATCHes the existing feature state to disabled' do
        client.disable_for_identity(:green_lanes, identity)
        expect(WebMock).to have_requested(:patch, "#{base_url}/#{identity_pk}/featurestates/99/")
          .with(body: { 'enabled' => false }.to_json)
      end
    end

    describe '#get_identity_overrides' do
      before do
        stub_request(:get, "#{base_url}/#{identity_pk}/featurestates/")
          .with(headers: admin_headers)
          .to_return(
            status: 200,
            body: {
              'results' => [
                { 'feature' => { 'name' => 'green_lanes' }, 'enabled' => true },
                { 'feature' => { 'name' => 'roo_wizard' }, 'enabled' => false },
              ],
            }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )
      end

      it 'returns only the names of enabled overrides' do
        expect(client.get_identity_overrides('User:neil@example.com')).to eq(['green_lanes'])
      end
    end

    describe '#delete_identity' do
      before do
        stub_request(:delete, "#{base_url}/#{identity_pk}/")
          .with(headers: admin_headers)
          .to_return(status: 204, body: '')
      end

      it 'DELETEs the identity by its pk' do
        client.delete_identity('User:neil@example.com')
        expect(WebMock).to have_requested(:delete, "#{base_url}/#{identity_pk}/")
      end
    end
  end
  ```

- [ ] **Step 2: Run to confirm they pass**

  ```bash
  bundle exec rspec spec/services/flagsmith_client_spec.rb --no-color
  ```

  Expected: 8 examples, 0 failures.

- [ ] **Step 3: Commit**

  ```bash
  git add spec/services/flagsmith_client_spec.rb
  git commit -m "Add FlagsmithClient Admin API mutation specs"
  ```

---

## Task 6: Add feature_enabled? and feature_value helpers

`feature_enabled?` is the single call site for all flag checks across the app. `feature_value` reads the feature's string value (used for the webchat URL). `webchat_url` and `webchat_enabled?` replace `TradeTariffFrontend.webchat_url` / `TradeTariffFrontend.webchat_enabled?` in helpers and views.

Flags are memoised on `Current.flagsmith_flags` so `FlagsmithClient#get_flags_for` is called at most once per request, not once per `feature_enabled?` call.

**Files:**
- Modify: `app/helpers/application_helper.rb`
- Modify: `spec/helpers/application_helper_spec.rb` (or create if missing)

- [ ] **Step 1: Check for an existing application_helper_spec**

  ```bash
  ls spec/helpers/
  ```

  If `application_helper_spec.rb` exists, open it. If not, create it empty for now.

- [ ] **Step 2: Write the failing tests**

  Add to `spec/helpers/application_helper_spec.rb`:

  ```ruby
  RSpec.describe ApplicationHelper, type: :helper do
    before do
      Current.flagsmith_identity = Flagsmith::UserIdentity.new('neil@example.com')
    end

    describe '#feature_enabled?' do
      context 'when the flag is on' do
        before { enable_feature(:green_lanes) }

        it 'returns true' do
          expect(helper.feature_enabled?(:green_lanes)).to be true
        end
      end

      context 'when the flag is off' do
        it 'returns false' do
          expect(helper.feature_enabled?(:green_lanes)).to be false
        end
      end

      it 'accepts a string flag name' do
        enable_feature(:green_lanes)
        expect(helper.feature_enabled?('green_lanes')).to be true
      end
    end

    describe '#feature_value' do
      it 'returns nil when no value is set' do
        expect(helper.feature_value(:webchat)).to be_nil
      end
    end

    describe '#webchat_enabled?' do
      it 'delegates to feature_enabled?(:webchat)' do
        enable_feature(:webchat)
        expect(helper.webchat_enabled?).to be true
      end
    end
  end
  ```

- [ ] **Step 3: Run to confirm they fail**

  ```bash
  bundle exec rspec spec/helpers/application_helper_spec.rb --no-color
  ```

  Expected: failures — `undefined method 'feature_enabled?'`.

- [ ] **Step 4: Add the helpers**

  In `app/helpers/application_helper.rb`, add these methods (place them near the top of the module, before other public methods):

  ```ruby
  # Returns true if the named flag is enabled for the current identity.
  # Memoises the flags collection on Current for the request lifetime so
  # FlagsmithClient is called at most once per request.
  def feature_enabled?(flag)
    Current.flagsmith_flags ||= FlagsmithClient.instance.get_flags_for(Current.flagsmith_identity)
    Current.flagsmith_flags.is_feature_enabled(flag.to_s)
  end

  # Returns the remote config value (string) for a named flag.
  # Used for flags that carry a value as well as an enabled state, e.g. webchat URL.
  def feature_value(flag)
    Current.flagsmith_flags ||= FlagsmithClient.instance.get_flags_for(Current.flagsmith_identity)
    Current.flagsmith_flags.get_feature_value(flag.to_s)
  end

  # The webchat URL stored as the :webchat flag's remote config value in FlagSmith.
  # Returns nil when the flag is not set or has no value.
  def webchat_url
    feature_value(:webchat)
  end

  # True when the :webchat flag is enabled in FlagSmith.
  def webchat_enabled?
    feature_enabled?(:webchat)
  end
  ```

- [ ] **Step 5: Run to confirm they pass**

  ```bash
  bundle exec rspec spec/helpers/application_helper_spec.rb --no-color
  ```

  Expected: 4 examples, 0 failures.

- [ ] **Step 6: Commit**

  ```bash
  git add app/helpers/application_helper.rb spec/helpers/application_helper_spec.rb
  git commit -m "Add feature_enabled?, feature_value, webchat_url helpers"
  ```

---

## Task 7: ApplicationController — identity resolution

Two `before_action`s replace the `TradeTariffFrontend` flag calls and the env-var-based `check_green_lanes_enabled`:

1. `set_current_flagsmith_identity` — resolves the current identity and stores it on `Current`
2. `migrate_anonymous_flagsmith_identity` — on first authenticated request after anonymous flag assignment, copies enabled overrides to the user identity and cleans up

Also update `set_path_info` and `check_green_lanes_enabled` which still call `TradeTariffFrontend`.

**Files:**
- Modify: `app/controllers/application_controller.rb`
- Modify: `spec/controllers/application_controller_spec.rb`

- [ ] **Step 1: Write the failing tests**

  Add to `spec/controllers/application_controller_spec.rb` (or create it — check `ls spec/controllers/`):

  ```ruby
  RSpec.describe ApplicationController, type: :controller do
    controller do
      def index
        render plain: 'ok'
      end
    end

    describe 'identity resolution' do
      context 'with no JWT cookie' do
        it 'sets an anonymous identity on Current' do
          get :index
          expect(Current.flagsmith_identity).to be_a(Flagsmith::AnonymousIdentity)
        end

        it 'stores the anonymous UUID in a cookie' do
          get :index
          expect(cookies[:flipper_anonymous_id]).to be_present
        end
      end

      context 'with a valid JWT cookie containing an email claim' do
        before do
          payload = { 'email' => 'neil@example.com', 'sub' => 'sub-123' }
          token = JWT.encode(payload, nil, 'none')
          cookies[TradeTariffFrontend.id_token_cookie_name] = token
        end

        it 'sets a user identity on Current' do
          get :index
          expect(Current.flagsmith_identity).to be_a(Flagsmith::UserIdentity)
          expect(Current.flagsmith_identity.identifier).to eq('User:neil@example.com')
        end
      end

      context 'with a JWT containing only a sub claim' do
        before do
          payload = { 'sub' => 'sub-only-123' }
          token = JWT.encode(payload, nil, 'none')
          cookies[TradeTariffFrontend.id_token_cookie_name] = token
        end

        it 'uses the sub claim as the user identifier' do
          get :index
          expect(Current.flagsmith_identity.identifier).to eq('User:sub-only-123')
        end
      end
    end

    describe '#check_green_lanes_enabled' do
      controller do
        before_action :check_green_lanes_enabled

        def index
          render plain: 'ok'
        end
      end

      context 'when green_lanes flag is enabled' do
        before { enable_feature(:green_lanes) }

        it 'allows the request' do
          get :index
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when green_lanes flag is disabled' do
        it 'raises FeatureUnavailable' do
          expect { get :index }.to raise_error(TradeTariffFrontend::FeatureUnavailable)
        end
      end
    end
  end
  ```

- [ ] **Step 2: Run to confirm they fail**

  ```bash
  bundle exec rspec spec/controllers/application_controller_spec.rb --no-color
  ```

  Expected: failures — missing `set_current_flagsmith_identity`.

- [ ] **Step 3: Add the before_actions and private methods**

  In `app/controllers/application_controller.rb`:

  1. Add to the `before_action` list (after `:bots_no_index_if_historical`):

     ```ruby
     before_action :set_current_flagsmith_identity
     before_action :migrate_anonymous_flagsmith_identity
     ```

  2. Replace the existing `set_path_info` method:

     ```ruby
     def set_path_info
       @path_info = { search_suggestions_path: search_suggestions_path(format: :json),
                      faq_send_feedback_path: green_lanes_send_feedback_path }

       if feature_enabled?(:interactive_search)
         @path_info[:interactive_search_suggestions_path] = interactive_search_suggestions_path(format: :json)
       end
     end
     ```

  3. Replace the existing `check_green_lanes_enabled` method:

     ```ruby
     def check_green_lanes_enabled
       unless feature_enabled?(:green_lanes)
         raise TradeTariffFrontend::FeatureUnavailable
       end
     end
     ```

  4. Add at the bottom of the `private` section:

     ```ruby
     def set_current_flagsmith_identity
       Current.flagsmith_identity = current_flagsmith_identity
     end

     def migrate_anonymous_flagsmith_identity
       return unless current_user_id
       return if cookies[:flipper_anonymous_id].blank?

       anonymous_id = cookies[:flipper_anonymous_id]
       user_identity = Flagsmith::UserIdentity.new(current_user_id)

       FlagsmithClient.instance.get_identity_overrides("Anonymous:#{anonymous_id}").each do |flag_name|
         FlagsmithClient.instance.enable_for_identity(flag_name, user_identity)
       end

       FlagsmithClient.instance.delete_identity("Anonymous:#{anonymous_id}")
       cookies.delete(:flipper_anonymous_id)
     end

     def current_flagsmith_identity
       user_id = current_user_id
       if user_id
         Flagsmith::UserIdentity.new(user_id)
       else
         Flagsmith::AnonymousIdentity.new(anonymous_flagsmith_id)
       end
     end

     def current_user_id
       token = cookies[TradeTariffFrontend.id_token_cookie_name]
       return nil if token.blank?

       payload, = JWT.decode(token, nil, false)
       payload['email'] || payload['sub']
     rescue JWT::DecodeError, ArgumentError
       nil
     end

     def anonymous_flagsmith_id
       return cookies[:flipper_anonymous_id] if cookies[:flipper_anonymous_id].present?

       uuid = SecureRandom.uuid
       cookies[:flipper_anonymous_id] = {
         value: uuid,
         max_age: 1.year.to_i,
         httponly: true,
         secure: Rails.env.production?,
       }
       uuid
     end
     ```

- [ ] **Step 4: Run to confirm they pass**

  ```bash
  bundle exec rspec spec/controllers/application_controller_spec.rb --no-color
  ```

  Expected: all examples pass.

- [ ] **Step 5: Commit**

  ```bash
  git add app/controllers/application_controller.rb spec/controllers/application_controller_spec.rb
  git commit -m "Add Flagsmith identity resolution and migration to ApplicationController"
  ```

---

## Task 8: FeatureOptInsController, initializer, and routes

The opt-in controller lets the app enable/disable a flag for the current identity (for beta opt-in flows). `MANAGEABLE_FEATURES` is the whitelist — it's empty for now but the infrastructure is in place. The initializer configures `FlagsmithClient` at boot from env vars.

**Files:**
- Create: `app/controllers/feature_opt_ins_controller.rb`
- Create: `spec/requests/feature_opt_ins_controller_spec.rb`
- Create: `config/initializers/flagsmith.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Write the failing tests**

  `spec/requests/feature_opt_ins_controller_spec.rb`:

  ```ruby
  RSpec.describe 'FeatureOptIns', type: :request do
    describe 'POST /feature_opt_ins' do
      context 'with a flag not in MANAGEABLE_FEATURES' do
        it 'returns 403' do
          post '/feature_opt_ins', params: { feature: 'green_lanes' }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    describe 'DELETE /feature_opt_ins/:id' do
      context 'with a flag not in MANAGEABLE_FEATURES' do
        it 'returns 403' do
          delete '/feature_opt_ins/green_lanes'
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
  ```

- [ ] **Step 2: Add the route**

  In `config/routes.rb`, after the existing `resources :feedbacks` line (or in a logical grouping), add:

  ```ruby
  resources :feature_opt_ins, only: %i[create destroy]
  ```

- [ ] **Step 3: Run to confirm the test fails correctly**

  ```bash
  bundle exec rspec spec/requests/feature_opt_ins_controller_spec.rb --no-color
  ```

  Expected: failures — `uninitialized constant FeatureOptInsController`.

- [ ] **Step 4: Implement the controller**

  `app/controllers/feature_opt_ins_controller.rb`:

  ```ruby
  class FeatureOptInsController < ApplicationController
    # Flags that users are allowed to opt in/out of via the UI.
    # Add flag names here when a beta opt-in flow is introduced.
    MANAGEABLE_FEATURES = %i[].freeze

    def create
      flag = params[:feature].to_sym
      return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

      FlagsmithClient.instance.enable_for_identity(flag, Current.flagsmith_identity)
      redirect_to_return_or_back
    end

    def destroy
      flag = params[:id].to_sym
      return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

      FlagsmithClient.instance.disable_for_identity(flag, Current.flagsmith_identity)
      redirect_to_return_or_back
    end

    private

    # Redirect to the explicit return_to path if it is a safe local path,
    # otherwise fall back to the Referer header or root.
    def redirect_to_return_or_back
      safe = safe_local_path(params[:return_to].to_s)
      if safe
        redirect_to safe, allow_other_host: false
      else
        redirect_back fallback_location: root_path
      end
    end

    # Returns only the path+query when return_to has no host component and
    # starts with /. Rejects absolute URLs, protocol-relative URLs, and
    # non-HTTP schemes regardless of string prefix tricks.
    def safe_local_path(raw)
      uri = URI.parse(raw)
      return nil unless uri.host.blank? && uri.path.to_s.start_with?('/')

      uri.query ? "#{uri.path}?#{uri.query}" : uri.path
    rescue URI::InvalidURIError
      nil
    end
  end
  ```

- [ ] **Step 5: Run to confirm the tests pass**

  ```bash
  bundle exec rspec spec/requests/feature_opt_ins_controller_spec.rb --no-color
  ```

  Expected: 2 examples, 0 failures.

- [ ] **Step 6: Write the initializer**

  `config/initializers/flagsmith.rb`:

  ```ruby
  # Configure FlagsmithClient with credentials from environment variables.
  #
  # FLAGSMITH_ENVIRONMENT_KEY — SDK key for the self-hosted environment.
  #   Used by the flagsmith gem to evaluate flags and read identity flags.
  # FLAGSMITH_API_URL — base URL of the self-hosted FlagSmith instance,
  #   e.g. https://flagsmith.example.com/api/v1/
  # FLAGSMITH_ADMIN_API_KEY — server-side key with write access, used for
  #   per-identity flag overrides and the anonymous→authenticated migration.
  #
  # In the test environment the singleton is replaced by a TestFlagsmithClient
  # double (see spec/support/flagsmith.rb) so these env vars are not required there.
  unless Rails.env.test?
    FlagsmithClient.configure(
      environment_key: ENV.fetch('FLAGSMITH_ENVIRONMENT_KEY'),
      api_url: ENV.fetch('FLAGSMITH_API_URL'),
      admin_api_key: ENV.fetch('FLAGSMITH_ADMIN_API_KEY'),
    )
  end
  ```

  Add a `configure` class method to `FlagsmithClient` — open `app/services/flagsmith_client.rb` and add inside `class << self`:

  ```ruby
  def configure(environment_key:, api_url:, admin_api_key:)
    @instance = new(environment_key:, api_url:, admin_api_key:)
  end
  ```

- [ ] **Step 7: Run the full suite to catch any regressions**

  ```bash
  bundle exec rspec spec/controllers/ spec/requests/ spec/services/ spec/models/ spec/helpers/ --no-color
  ```

  Expected: all pass.

- [ ] **Step 8: Commit**

  ```bash
  git add app/controllers/feature_opt_ins_controller.rb \
          spec/requests/feature_opt_ins_controller_spec.rb \
          config/initializers/flagsmith.rb \
          app/services/flagsmith_client.rb \
          config/routes.rb
  git commit -m "Add FeatureOptInsController, Flagsmith initializer, and routes"
  ```

---

## Task 9: Migrate call sites and remove old env-var flag methods

Replace every `TradeTariffFrontend.green_lanes_enabled?`, `TradeTariffFrontend.interactive_search_enabled?`, `TradeTariffFrontend.webchat_enabled?`, `TradeTariffFrontend.webchat_url`, `TradeTariffFrontend.roo_wizard?`, and `TradeTariffFrontend.single_trade_window_linking_enabled?` with `feature_enabled?` (or `webchat_url` for the URL value). Then delete the six methods from `lib/trade_tariff_frontend.rb`.

**Files:**
- Modify: `app/controllers/concerns/interactive_searchable.rb`
- Modify: `app/controllers/find_commodities_controller.rb`
- Modify: `app/controllers/search_controller.rb`
- Modify: `app/controllers/green_lanes/category_assessments_controller.rb`
- Modify: `app/models/search.rb`
- Modify: `app/helpers/webchat_helper.rb`
- Modify: `app/helpers/intercept_guidance_helper.rb`
- Modify: `app/views/search/_interactive_error_sidebar.html.erb`
- Modify: `app/views/search/_interactive_results_sidebar.html.erb`
- Modify: `app/views/search/_interactive_support_links.html.erb`
- Modify: `app/views/shared/webchat_message/_footer.html.erb`
- Modify: `app/views/shared/webchat_message/_help.html.erb`
- Modify: `app/views/shared/webchat_message/_not_found.html.erb`
- Modify: `app/views/measures/_measures.html.erb`
- Modify: `app/views/shared/_stw_link.html.erb`
- Modify: `lib/trade_tariff_frontend.rb`

- [ ] **Step 1: Verify the full call-site list before touching anything**

  ```bash
  grep -rn "TradeTariffFrontend\.green_lanes_enabled\?\|TradeTariffFrontend\.interactive_search_enabled\?\|TradeTariffFrontend\.webchat_enabled\?\|TradeTariffFrontend\.webchat_url\|TradeTariffFrontend\.roo_wizard\?\|TradeTariffFrontend\.single_trade_window_linking_enabled\?\|TradeTariffFrontend\.welsh\?" app/ --include="*.rb" --include="*.erb"
  ```

  Review every hit. The list should match the files above exactly.

- [ ] **Step 2: Replace in Ruby files**

  `app/controllers/concerns/interactive_searchable.rb` — two occurrences of `TradeTariffFrontend.interactive_search_enabled?`:

  ```ruby
  # line ~33 (in SearchController#suggestions)
  return suggestions unless feature_enabled?(:interactive_search)

  # line ~78 (in #interactive_search?)
  def interactive_search?
    @search.interactive_search && feature_enabled?(:interactive_search)
  end
  ```

  `app/controllers/find_commodities_controller.rb`:

  ```ruby
  render :show_interactive if feature_enabled?(:interactive_search)
  ```

  `app/controllers/search_controller.rb`:

  ```ruby
  return suggestions unless feature_enabled?(:interactive_search)
  ```

  `app/controllers/green_lanes/category_assessments_controller.rb`:

  ```ruby
  raise TradeTariffFrontend::FeatureUnavailable unless feature_enabled?(:green_lanes)
  ```

  `app/models/search.rb` — `TradeTariffFrontend.interactive_search_enabled?` is called from a model, not a controller/view. Models don't include `ApplicationHelper`. Add a private method to `search.rb`:

  Replace:
  ```ruby
  if interactive_search && TradeTariffFrontend.interactive_search_enabled?
  ```
  With:
  ```ruby
  if interactive_search && interactive_search_enabled?
  ```

  And add a private method at the bottom of the `Search` class:

  ```ruby
  private

  def interactive_search_enabled?
    flags = Current.flagsmith_flags || FlagsmithClient.instance.get_flags_for(Current.flagsmith_identity)
    flags.is_feature_enabled('interactive_search')
  end
  ```

  `app/helpers/webchat_helper.rb` — replace `TradeTariffFrontend.webchat_url` with `webchat_url` (the helper defined in Task 6):

  ```ruby
  module WebchatHelper
    def webchat_link(text = 'Digital Assistant (opens in new tab)')
      link_to(text, webchat_url, target: '_blank', rel: 'noopener')
    end

    def webchat_visible_in_footer?
      %w[commodities headings subheadings chapters sections].include?(controller_name)
    end
  end
  ```

  `app/helpers/intercept_guidance_helper.rb` — replace `TradeTariffFrontend.webchat_url` with `webchat_url`:

  ```ruby
  'webchat_url' => ->(_) { webchat_url },
  ```

- [ ] **Step 3: Replace in views**

  `app/views/search/_interactive_error_sidebar.html.erb` — replace `TradeTariffFrontend.webchat_enabled?`:

  ```erb
  <% if webchat_enabled? %>
  ```

  `app/views/search/_interactive_results_sidebar.html.erb`:

  ```erb
  <% if webchat_enabled? %>
  ```

  `app/views/search/_interactive_support_links.html.erb`:

  ```erb
  <% if webchat_enabled? %>
  ```

  `app/views/shared/webchat_message/_footer.html.erb`:

  ```erb
  <% if webchat_enabled? %>
  ```

  `app/views/shared/webchat_message/_help.html.erb`:

  ```erb
  <% if webchat_enabled? %>
  ```

  `app/views/shared/webchat_message/_not_found.html.erb`:

  ```erb
  <% if webchat_enabled? %>
  ```

  `app/views/measures/_measures.html.erb` — replace `TradeTariffFrontend.roo_wizard?`:

  ```erb
  <%= render (feature_enabled?(:roo_wizard) ? 'rules_of_origin/tab_' + tariff_tab : 'rules_of_origin/legacy/tab'),
  ```

  `app/views/shared/_stw_link.html.erb` — replace `TradeTariffFrontend.single_trade_window_linking_enabled?`:

  ```erb
  <% if feature_enabled?(:stw) %>
  ```

- [ ] **Step 4: Delete the six methods from TradeTariffFrontend**

  In `lib/trade_tariff_frontend.rb`, remove these methods entirely:

  - `def welsh?` (lines ~117-119)
  - `def roo_wizard?` (lines ~121-123)
  - `def webchat_enabled?` (lines ~125-127)
  - `def webchat_url` (lines ~129-135)
  - `def green_lanes_enabled?` (lines ~141-143)
  - `def interactive_search_enabled?` (lines ~145-147)

  Also remove the `WEBCHAT_BASE_URL` constant at the top of the file (line 4), as nothing will reference it after the removal.

- [ ] **Step 5: Confirm no old call sites remain**

  ```bash
  grep -rn "TradeTariffFrontend\.green_lanes_enabled\?\|TradeTariffFrontend\.interactive_search_enabled\?\|TradeTariffFrontend\.webchat_enabled\?\|TradeTariffFrontend\.webchat_url\|TradeTariffFrontend\.roo_wizard\?\|TradeTariffFrontend\.single_trade_window_linking_enabled\?\|TradeTariffFrontend\.welsh\?\|WEBCHAT_BASE_URL" app/ lib/ --include="*.rb" --include="*.erb"
  ```

  Expected: no output.

- [ ] **Step 6: Run the full test suite**

  ```bash
  bundle exec rspec --no-color
  ```

  Expected: all examples pass, 0 failures. If any spec stubs `TradeTariffFrontend.webchat_url` or similar, update those stubs to use `enable_feature(:webchat)` or stub `webchat_url` via `allow(helper).to receive(:webchat_url)` instead.

- [ ] **Step 7: Run RuboCop**

  ```bash
  bundle exec rubocop app/controllers/ app/helpers/ app/models/ app/services/ app/views/ lib/trade_tariff_frontend.rb config/ spec/ --no-color
  ```

  Fix any offenses before committing.

- [ ] **Step 8: Commit**

  ```bash
  git add app/ lib/trade_tariff_frontend.rb config/ spec/
  git commit -m "Migrate call sites to feature_enabled? and remove TradeTariffFrontend flag methods"
  ```

---

## Done

At this point the FlagSmith integration is complete on `feature/flagsmith-integration`. All existing env-var flags are replaced with `feature_enabled?` backed by self-hosted FlagSmith. The test suite uses an in-memory double with no real HTTP calls.

To compare against the Flipper Cloud branch, check out `feature/flipper-cloud-integration` and evaluate:
- Number of gem dependencies
- Complexity of the Admin API calls vs `Flipper.enable_actor`
- Ops burden (FlagSmith service to maintain vs Flipper Cloud subscription)
- SDK quality and test support ergonomics
