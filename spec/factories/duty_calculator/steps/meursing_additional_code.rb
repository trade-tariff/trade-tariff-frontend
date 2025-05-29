FactoryBot.define do
  factory :meursing_additional_code, class: 'DutyCalculator::Steps::MeursingAdditionalCode', parent: :step do
    transient do
      possible_attributes { { meursing_additional_code: 'meursing_additional_code' } }
    end

    meursing_additional_code { nil }
  end
end
