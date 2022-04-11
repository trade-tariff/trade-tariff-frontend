FactoryBot.define do
  factory :additional_code do
    additional_code_type_id { Forgery(:basic).text(exactly: 1).upcase }
    additional_code { Forgery(:basic).text(exactly: 3).upcase }
    code { Forgery(:basic).text(exactly: 4).upcase }
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    measures { [attributes_for(:measure)] }
  end
end
