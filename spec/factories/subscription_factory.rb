FactoryBot.define do
  factory :subscription do
    active { true }
    uuid { SecureRandom.uuid }
  end
end
