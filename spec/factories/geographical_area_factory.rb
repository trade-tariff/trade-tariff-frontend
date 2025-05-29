FactoryBot.define do
  factory :duty_calculator_geographical_area, class: 'DutyCalculator::GeographicalArea' do
    transient do
      child_area_ids { [] }
    end

    id { Forgery(:basic).text(exactly: 2).upcase }
    description { Forgery(:basic).text }
    geographical_area_id { id }

    children_geographical_areas do
      child_area_ids.map do |child_id|
        attributes_for :geographical_area, id: child_id
      end
    end

    trait :specific_country do
      description { Forgery(:basic).text }
    end

    trait :erga_omnes do
      id { '1011' }
    end

    trait :japan do
      id { 'JP' }
      description { 'Japan' }
    end
  end
end
