# Extend Rails cache to handle deserialization errors gracefully
module CacheResilience
  # Resilient fetch that handles deserialization errors by falling back to computing the value
  # Usage: Rails.cache.resilient_fetch('key') { expensive_operation }
  def resilient_fetch(key, options = {})
    fetch(key, options) do
      yield
    end
  rescue => e
    Rails.logger.error("Cache deserialization error for key #{key}: #{e.class} - #{e.message}")
    # Return the computed value without caching
    yield
  end
end

# Patch ActiveSupport::Cache::Store to include the resilient_fetch method
ActiveSupport::Cache::Store.include(CacheResilience)
