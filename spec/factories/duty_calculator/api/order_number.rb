FactoryBot.define do
  factory :duty_calculator_order_number, class: 'DutyCalculator::Api::OrderNumber' do
    id { '058048' }
    number { '058048' }
    definition { attributes_for :definition }
  end
end
