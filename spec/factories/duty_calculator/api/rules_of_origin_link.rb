FactoryBot.define do
  factory :rules_of_origin_link, class: 'DutyCalculator::Api::RulesOfOrigin::Link' do
    text { 'Check your goods meet the rules of origin' }
    url { 'https://www.gov.uk/guidance/check-your-goods-meet-the-rules-of-origin' }
  end
end
