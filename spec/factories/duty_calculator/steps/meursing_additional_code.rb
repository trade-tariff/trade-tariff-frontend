FactoryBot.define do
  factory :duty_calculator_meursing_additional_code, class: 'DutyCalculator::Steps::MeursingAdditionalCode', parent: :duty_calculator_step do
    transient do
      possible_attributes { { meursing_additional_code: 'meursing_additional_code' } }
    end

    meursing_additional_code { nil }
  end
end
