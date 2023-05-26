require 'api_entity'

FactoryBot.define do
  factory :measurement_unit_qualifier do
    resource_id { 'E' }
    description { 'of drained net weight' }
    formatted_description { 'of drained net weight' }
  end
end
