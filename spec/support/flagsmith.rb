# In-memory stand-in for the real FlagsmithClient. Holds a simple hash of
# flag_name => enabled. All flags default to disabled.
# Shared across threads (it is a constant, not thread-local), so Puma server
# threads in JS tests see the same state as the test thread.
class TestFlagsmithClient
  class TestFlags
    def initialize(flags)
      @flags = flags
    end

    def is_feature_enabled(flag_name)
      @flags.fetch(flag_name.to_s, false)
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

  # FlagsmithClient interface - evaluation
  def get_flags_for(_identity)
    TestFlags.new(@flags)
  end
end

TEST_FLAGSMITH_CLIENT = TestFlagsmithClient.new

RSpec.configure do |config|
  config.before(:suite) do
    next unless defined?(FlagsmithClient)

    FlagsmithClient.instance = TEST_FLAGSMITH_CLIENT
  end

  config.before do
    TEST_FLAGSMITH_CLIENT.reset!
    Current.reset
  end
end

# Test helpers - product-agnostic names so specs don't mention FlagSmith directly.
def enable_feature(flag)
  TEST_FLAGSMITH_CLIENT.set_flag(flag, true)
end

def disable_feature(flag)
  TEST_FLAGSMITH_CLIENT.set_flag(flag, false)
end
