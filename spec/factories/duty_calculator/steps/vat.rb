FactoryBot.define do
  factory :vat, class: 'DutyCalculator::Steps::Vat', parent: :step do
    transient do
      possible_attributes { { vat: 'vat' } }
    end

    vat { nil }
  end
end
