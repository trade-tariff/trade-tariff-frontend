FactoryBot.define do
  factory :geographical_area, class: 'DutyCalculator::Api::GeographicalArea' do
    id { 'GB' }
    geographical_area_id { 'GB' }
    description { 'United Kingdom' }

    children_geographical_areas { [] }
  end
end
