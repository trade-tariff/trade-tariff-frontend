FactoryBot.define do
  sequence(:additional_code_sid)

  factory :duty_calculator_additional_code, class: 'DutyCalculator::Api::AdditionalCode' do
    id { generate(:additional_code_sid) }
    code {}
    description {}
    formatted_description {}
  end

  trait :vatz do
    code { 'VATZ' }
    description { 'VAT zero rate' }
    formatted_description { 'VAT zero rate' }
  end

  trait :company do
    code { 'C490' }
    description { 'COFCO International Argentina S.A.' }
    formatted_description { 'COFCO International Argentina S.A.' }
  end

  trait :excise do
    code { 'X99A' }
    description { 'CLIMATE CHANGE LEVY (CCL), 990, solid' }
    formatted_description { 'CLIMATE CHANGE LEVY (CCL), 990, solid' }
  end

  trait :excise_spq do
    code { 'X444' }
    description { 'Spirits at least 3.5 but less than 8.5% &amp; eligible for SPR and DR' }
    formatted_description { 'Spirits at least 3.5 but less than 8.5% &amp; eligible for SPR and DR' }
  end
end
