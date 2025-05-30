FactoryBot.define do
  sequence(:measure_condition_component_sid)

  factory :duty_calculator_measure_condition_component, class: 'DutyCalculator::Api::MeasureConditionComponent' do
    transient do
      measure_condition_sid {}
    end

    id { "#{measure_condition_sid}-#{generate(:measure_condition_component_sid)}" }
    duty_expression_id {}
    duty_amount {}
    monetary_unit_code {}
    monetary_unit_abbreviation {}
    measurement_unit_code {}
    measurement_unit_qualifier_code {}
    duty_expression_description {}
    duty_expression_abbreviation {}

    trait :with_measure_units do
      duty_amount { 35.1 }
      measurement_unit_code { 'DTN' }
      duty_expression_abbreviation { '% or amount' }
      duty_expression_description { '%' }
      duty_expression_id { '01' }
    end

    trait :spq_lpa do
      duty_amount { 19.080000000000002 }
      duty_expression_id { '01' }
      monetary_unit_code { 'GBP' }
      monetary_unit_abbreviation { nil }
      measurement_unit_code { 'LPA' }
      measurement_unit_qualifier_code { nil }
      duty_expression_description { '% or amount' }
      duty_expression_abbreviation { '%' }
    end

    trait :spq_asvx do
      duty_amount { 19.080000000000002 }
      duty_expression_id { '01' }
      monetary_unit_code { 'GBP' }
      monetary_unit_abbreviation { nil }
      measurement_unit_code { 'ASV' }
      measurement_unit_qualifier_code { 'X' }
      duty_expression_description { '% or amount' }
      duty_expression_abbreviation { '%' }
    end

    trait :spq do
      duty_amount { 1 }
      duty_expression_id { '02' }
      measurement_unit_code { 'SPQ' }
      duty_expression_description { 'minus % or amount' }
      duty_expression_abbreviation { '-' }
      monetary_unit_code { 'GBP' }
      monetary_unit_abbreviation { nil }
    end
  end
end
