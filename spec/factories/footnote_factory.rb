FactoryBot.define do
  factory :footnote do
    code { Forgery(:basic).text }
    description { Forgery(:basic).text }
  end
end
