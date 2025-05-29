FactoryBot.define do
  factory :annual_turnover, class: 'DutyCalculator::Steps::AnnualTurnover', parent: :step do
    transient do
      possible_attributes { { annual_turnover: 'annual_turnover' } }
    end

    annual_turnover { '' }
  end
end
