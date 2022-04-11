FactoryBot.define do
  factory :certificate do
    certificate_type_code { Forgery(:basic).text(exactly: 1).upcase }
    certificate_code { Forgery(:basic).text(exactly: 3).upcase }
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    measures { [attributes_for(:measure)] }
  end
end
