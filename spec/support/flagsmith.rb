# In-memory stand-in for the real FlagsmithClient. Holds a simple hash of
# flag_name => enabled. All flags default to disabled.
# Shared across threads (it is a constant, not thread-local), so Puma server
# threads in JS tests see the same state as the test thread.
class TestFlagsmithClient
  class TestFlag
    attr_reader :enabled, :default, :feature_name

    def initialize(feature_name:, enabled:, default:)
      @feature_name = feature_name
      @enabled = enabled
      @default = default
    end

    def enabled?
      enabled
    end

    alias_method :is_default, :default
  end

  class TestFlags
    def initialize(flags)
      @flags = flags
    end

    def is_feature_enabled(flag_name)
      get_flag(flag_name).enabled?
    end

    def get_flag(flag_name)
      flag_name = flag_name.to_s

      if @flags.key?(flag_name)
        TestFlag.new(feature_name: flag_name, enabled: @flags.fetch(flag_name), default: false)
      else
        TestFlag.new(feature_name: flag_name, enabled: false, default: true)
      end
    end

    def all_flags
      @flags.map { |name, enabled| TestFlag.new(feature_name: name, enabled: enabled, default: false) }
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

class TestFlagsmithManagementClient
  attr_reader :recorded_traits

  def initialize
    @recorded_traits = []
  end

  def reset!
    @recorded_traits = []
  end

  def get_flags_for(identity) # rubocop:disable Rails/Delegate
    TEST_FLAGSMITH_CLIENT.get_flags_for(identity)
  end

  def set_trait(identifier, trait_key, trait_value)
    @recorded_traits << { identifier:, trait_key:, trait_value: }
  end
end

TEST_FLAGSMITH_CLIENT = TestFlagsmithClient.new
TEST_FLAGSMITH_MANAGEMENT_CLIENT = TestFlagsmithManagementClient.new

RSpec.configure do |config|
  config.before(:suite) do
    FlagsmithClient.instance = TEST_FLAGSMITH_CLIENT if defined?(FlagsmithClient)
    FlagsmithManagementClient.instance = TEST_FLAGSMITH_MANAGEMENT_CLIENT if defined?(FlagsmithManagementClient)
  end

  config.before do
    TEST_FLAGSMITH_CLIENT.reset!
    TEST_FLAGSMITH_MANAGEMENT_CLIENT.reset!
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
