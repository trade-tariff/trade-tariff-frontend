FactoryBot.define do
  factory :subscription do
    active { true }
    uuid { SecureRandom.uuid }
    resource_id { uuid }
    subscription_type { { name: Subscription::SUBSCRIPTION_TYPES[:my_commodities] } }

    trait :stop_press do
      subscription_type { { name: Subscription::SUBSCRIPTION_TYPES[:stop_press] } }
      meta do
        {
          published: { yesterday: 5 },
          chapters: 10,
        }
      end
    end

    trait :my_commodities do
      subscription_type { { name: Subscription::SUBSCRIPTION_TYPES[:my_commodities] } }
      meta do
        {
          published: { yesterday: 3 },
          counts: { 'active' => 3, 'expired' => 2, 'invalid' => 1, 'total' => 5 },
        }
      end
    end
  end
end
