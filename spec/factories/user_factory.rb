FactoryBot.define do
  factory :user do
    email { 'user@example.com' }
    chapter_ids { '11,23' }
    subscriptions { [] }
  end
end
