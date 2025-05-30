FactoryBot.define do
  factory :duty_calculator_rules_of_origin_proof, class: 'DutyCalculator::Api::RulesOfOrigin::Proof' do
    summary { 'EUR1 or EUR.MED movement certificate' }
    subtext { '' }
    url { 'https://www.gov.uk/guidance/get-proof-of-origin-for-your-goods#eur1-and-eur-med-movement-certificates' }
  end
end
