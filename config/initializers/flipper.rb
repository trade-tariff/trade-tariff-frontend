# Flipper initialization
# In test environment, spec/support/flipper.rb handles setup with memory adapter
# In production, Cloud token is set via environment variable
unless Rails.env.test?
  if ENV['FLIPPER_CLOUD_TOKEN'].present?
    Flipper.configure do |config|
      config.default { Flipper::Cloud.new }
    end
  else
    # Development uses memory adapter
    Flipper.configure do |config|
      config.default { Flipper.new(Flipper::Adapters::Memory.new) }
    end
  end
end
