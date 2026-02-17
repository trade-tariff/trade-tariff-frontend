FactoryBot.define do
  factory :subscription do
    active { true }
    uuid { SecureRandom.uuid }
    resource_id { uuid }
    subscription_type do
      {
        id: SecureRandom.uuid,
        name: SubscriptionType::SUBSCRIPTION_TYPE_NAMES[:my_commodities],
        resource_type: 'subscription_type',
      }
    end

    trait :stop_press do
      subscription_type do
        {
          id: SecureRandom.uuid,
          name: SubscriptionType::SUBSCRIPTION_TYPE_NAMES[:stop_press],
          resource_type: 'subscription_type',
        }
      end
    end

    trait :my_commodities do
      subscription_type do
        {
          id: SecureRandom.uuid,
          name: SubscriptionType::SUBSCRIPTION_TYPE_NAMES[:my_commodities],
          resource_type: 'subscription_type',
        }
      end
      meta do
        {
          'counts' => { 'active' => 3, 'expired' => 0, 'invalid' => 4, 'total' => 3 },
          'published' => { 'yesterday' => 0 },
        }
      end
    end
  end
end
