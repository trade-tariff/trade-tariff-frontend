FactoryBot.define do
  factory :order_number do
    number { Forgery(:basic).number(exactly: 6).to_s }
  end
end
