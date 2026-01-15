FactoryBot.define do
  factory :subscription_target do
    target_type { 'my_commodities' }
    target_object do
      build(:tariff_changes_commodity).attributes.symbolize_keys
    end
  end
end
