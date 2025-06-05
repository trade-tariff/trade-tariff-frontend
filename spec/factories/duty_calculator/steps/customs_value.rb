FactoryBot.define do
  factory :duty_calculator_customs_value, class: 'DutyCalculator::Steps::CustomsValue', parent: :duty_calculator_step do
    transient do
      possible_attributes do
        {
          monetary_value: 'monetary_value',
          insurance_cost: 'insurance_cost',
          shipping_cost: 'shipping_cost',
        }
      end
    end

    monetary_value { '' }
    insurance_cost { '' }
    shipping_cost { '' }
  end
end
