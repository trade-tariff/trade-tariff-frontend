# In-memory stand-in for the real FlagsmithClient. Holds a simple hash of
# flag_name => { enabled, value }. All flags default to disabled with nil value.
# Shared across threads (it is a constant, not thread-local), so Puma server
# threads in JS tests see the same state as the test thread.
class TestFlagsmithClient
  class TestFlags
    def initialize(flags)
      @flags = flags
    end

    def is_feature_enabled(flag_name)
      @flags.dig(flag_name.to_s, :enabled) || false
    end

    def get_feature_value(flag_name)
      @flags.dig(flag_name.to_s, :value)
    end
  end

  def initialize
    @flags = {}
  end

  def set_flag(flag, enabled)
    @flags[flag.to_s] ||= {}
    @flags[flag.to_s][:enabled] = enabled
  end

  def set_feature_value(flag, value)
    @flags[flag.to_s] ||= {}
    @flags[flag.to_s][:value] = value
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

# Sets the remote config value for a feature flag (e.g. the webchat URL stored
# in the :webchat flag's value field).
# rubocop:disable Rails/Delegate
def set_feature_value(flag, value)
  TEST_FLAGSMITH_CLIENT.set_feature_value(flag, value)
end
# rubocop:enable Rails/Delegate
