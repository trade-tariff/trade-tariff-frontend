FactoryBot.define do
  factory :duty_calculator_geographical_area, class: 'DutyCalculator::Api::GeographicalArea' do
    id { 'GB' }
    geographical_area_id { 'GB' }
    description { 'United Kingdom' }

    children_geographical_areas { [] }
  end
end
