FactoryBot.define do
  factory :user do
    email { 'user@example.com' }
    chapter_ids { '11,23' }
    stop_press_subscription { false }
  end
end
