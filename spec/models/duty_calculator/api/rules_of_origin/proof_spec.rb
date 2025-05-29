RSpec.describe DutyCalculator::Api::RulesOfOrigin::Proof do
  it_behaves_like 'a resource that has attributes',
                  summary: 'EUR1 or EUR.MED movement certificate',
                  subtext: '',
                  url: 'https://www.gov.uk/guidance/get-proof-of-origin-for-your-goods#eur1-and-eur-med-movement-certificates'
end
