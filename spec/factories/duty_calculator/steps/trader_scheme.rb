FactoryBot.define do
  factory :duty_calculator_trader_scheme, class: 'DutyCalculator::Steps::TraderScheme', parent: :duty_calculator_step do
    transient do
      possible_attributes { { trader_scheme: 'trader_scheme' } }
    end

    trader_scheme { '' }
  end
end
