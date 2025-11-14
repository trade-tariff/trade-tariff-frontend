FactoryBot.define do
  factory :subscription do
    active { true }
    uuid { SecureRandom.uuid }
    resource_id { uuid }
    subscription_type { 'my_commodities' }
    metadata { { commodity_codes: %w[1234567890 1234567891 1234567892 1234567893] } }
    meta { { active: %w[1234567890], expired: %w[1234567891], invalid: %w[1234567892] } }
  end
end
