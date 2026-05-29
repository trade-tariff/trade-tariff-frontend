# spec/support/flipper.rb
#
# Reset Flipper to a clean in-memory adapter before each test.
#
# Flipper.instance= stores the DSL object in Thread.current. For Capybara
# JS tests, the Rails app runs in Puma worker threads that have their own
# Thread.current, making per-thread Flipper instances invisible across
# thread boundaries.
#
# We solve this by using a single process-level memory adapter stored in a
# constant. All threads share the same adapter object. Before each test we
# clear its feature store so previous test state does not bleed across.
# Calling Flipper.instance = nil clears the test thread's cache so it falls
# back to configuration.default. Puma threads with a stale cached DSL still
# see cleared flags because they all wrap the same FLIPPER_TEST_ADAPTER.

FLIPPER_TEST_ADAPTER = Flipper::Adapters::Memory.new

Flipper.configure do |config|
  config.adapter { FLIPPER_TEST_ADAPTER }
end

RSpec.configure do |config|
  config.before do
    # Remove every known feature from the shared adapter.
    # Memory#features returns a Set of string keys (the feature names).
    # We pass a simple wrapper that responds to #key so that Memory#remove
    # can locate and delete the entry from its @source hash.
    feature_key = Struct.new(:key)
    FLIPPER_TEST_ADAPTER.features.each do |key|
      FLIPPER_TEST_ADAPTER.remove(feature_key.new(key))
    end
    # Clear the per-thread DSL cache on the test thread.
    Flipper.instance = nil
    Current.reset
  end
end
