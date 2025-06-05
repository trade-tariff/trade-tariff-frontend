FactoryBot.define do
  factory :duty_calculator_vat, class: 'DutyCalculator::Steps::Vat', parent: :duty_calculator_step do
    transient do
      possible_attributes { { vat: 'vat' } }
    end

    vat { nil }
  end
end
