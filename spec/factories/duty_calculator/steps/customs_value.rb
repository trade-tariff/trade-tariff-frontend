FactoryBot.define do
  factory :customs_value, class: 'DutyCalculator::Steps::CustomsValue', parent: :step do
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
