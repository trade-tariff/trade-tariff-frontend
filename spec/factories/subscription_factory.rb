FactoryBot.define do
  factory :subscription do
    active { true }
    uuid { SecureRandom.uuid }
    resource_id { uuid }
    meta { { active: 1, expired: 1, invalid: 1 } }
    subscription_type { { 'name' => Subscription::SUBSCRIPTION_TYPES[:my_commodities] } }
  end
end
