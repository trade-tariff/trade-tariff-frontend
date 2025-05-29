RSpec.describe DutyCalculator::Api::RulesOfOrigin::Link do
  it_behaves_like 'a resource that has attributes',
                  text: 'Check your goods meet the rules of origin',
                  url: 'https://www.gov.uk/guidance/check-your-goods-meet-the-rules-of-origin'
end
