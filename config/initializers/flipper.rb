# frozen_string_literal: true

# Configure Flipper to use Redis as the local adapter.
#
# When FLIPPER_CLOUD_TOKEN is present, Flipper::Engine (loaded automatically
# via the flipper-cloud gem) will wrap this adapter with the Cloud HTTP adapter,
# keeping the local Redis store in sync via webhook or polling.
#
# When FLIPPER_CLOUD_TOKEN is absent (development without credentials, test),
# the Redis adapter is used directly. In tests, spec/support/flipper.rb resets
# Flipper.instance to a memory adapter before each example, so this is moot.
Flipper.configure do |config|
  config.adapter do
    Flipper::Adapters::Redis.new(Redis.new(url: ENV['REDIS_URL']))
  end
end
