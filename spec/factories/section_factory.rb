FactoryBot.define do
  factory :section do
    title    { Forgery(:basic).text }
    position { 1 }
  end
end
