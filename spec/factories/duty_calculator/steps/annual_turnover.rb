FactoryBot.define do
  factory :duty_calculator_annual_turnover, class: 'DutyCalculator::Steps::AnnualTurnover', parent: :duty_calculator_step do
    transient do
      possible_attributes { { annual_turnover: 'annual_turnover' } }
    end

    annual_turnover { '' }
  end
end
