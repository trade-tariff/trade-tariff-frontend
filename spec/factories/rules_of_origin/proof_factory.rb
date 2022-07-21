FactoryBot.define do
  factory :rules_of_origin_proof, class: 'RulesOfOrigin::Proof' do
    sequence(:summary) { |n| "Proof summary #{n}" }
    url { 'https://www.gov.uk/' }
    sequence(:subtext) { |n| "Proof subtext #{n}" }
  end
end
