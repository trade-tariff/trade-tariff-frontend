RSpec.describe DutyCalculator::Api::DutyExpression do
  it_behaves_like 'a resource that has attributes',
                  id: 'flibble',
                  base: '0.00 %',
                  formatted_base: '<span>0.00</span> %'
end
