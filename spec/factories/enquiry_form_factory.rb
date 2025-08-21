FactoryBot.define do
  factory :enquiry_form do
    name { 'John Doe' }
    company_name { 'Acme Corp' }
    job_title { 'Engineer' }
    email { 'john.doe@example.com' }
    enquiry_category { 'classification' }
    enquiry_description { 'This is a test enquiry.' }
  end
end
