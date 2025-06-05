FactoryBot.define do
  factory :duty_calculator_measure_type, class: 'DutyCalculator::Api::MeasureType' do
    id {}
    description {}
    national { false }
    measure_type_series_id {}

    trait :third_country do
      id { '103' }
      description { 'Third country duty' }
      measure_type_series_id { 'C' }
    end

    trait :third_country_authorised_use do
      id { '105' }
      description { 'Non preferential duty under authorised use' }
      measure_type_series_id { 'C' }
    end

    trait :autonomous do
      id { '112' }
      description { 'Autonomous tariff suspension' }
      measure_type_series_id { 'C' }
    end

    trait :autonomous_end_use do
      id { '115' }
      description { 'Autonomous suspension under end-use' }
      measure_type_series_id { 'C' }
    end

    trait :certain_category_goods do
      id { '117' }
      description { 'Suspension - goods for certain categories of ships, boats and other vessels and for drilling or production platforms' }
      measure_type_series_id { 'C' }
    end

    trait :airworthiness do
      id { '119' }
      description { 'Airworthiness tariff suspension' }
      measure_type_series_id { 'C' }
    end

    trait :preferential_suspension do
      id { '141' }
      description { 'Preferential suspension' }
      measure_type_series_id { 'C' }
    end

    trait :non_preferential do
      id { '122' }
      description { 'Non preferential tariff quota' }
      measure_type_series_id { 'C' }
    end

    trait :non_preferential_end_use do
      id { '123' }
      description { 'Non preferential tariff quota under end-use' }
      measure_type_series_id { 'C' }
    end

    trait :tariff_preference do
      id { '142' }
      description { 'Tariff preference' }
      measure_type_series_id { 'C' }
    end

    trait :preferential do
      id { '143' }
      description { 'Preferential tariff quota' }
      measure_type_series_id { 'C' }
    end

    trait :preferential_end_use do
      id { '146' }
      description { 'Preferential tariff quota under end-use' }
      measure_type_series_id { 'C' }
    end

    trait :customs_union do
      id { '147' }
      description { 'Customs Union Quota' }
      measure_type_series_id { 'C' }
    end

    trait :vat do
      id { '305' }
      description { 'Value added tax' }
      measure_type_series_id { 'P' }
    end

    trait :excise do
      id { '306' }
      description { 'Excise' }
      measure_type_series_id { 'Q' }
    end

    trait :authorised_use_provisions_submission do
      id { '464' }
      description { 'Declaration of subheading submitted to authorised use provisions' }
      measure_type_series_id { 'B' }
    end

    trait :provisional_anti_dumping do
      id { '551' }
      description { 'Provisional anti-dumping duty' }
      measure_type_series_id { 'D' }
    end

    trait :definitive_anti_dumping do
      id { '552' }
      description { 'Definitive anti-dumping duty' }
      measure_type_series_id { 'D' }
    end

    trait :provisional_countervailing do
      id { '553' }
      description { 'Provisional countervailing duty' }
      measure_type_series_id { 'D' }
    end

    trait :definitive_countervailing do
      id { '554' }
      description { 'Definitive countervailing duty' }
      measure_type_series_id { 'D' }
    end

    trait :additional_duties do
      id { '695' }
      description { 'Additional duties' }
      measure_type_series_id { 'J' }
    end

    trait :additional_duties_safeguard do
      id { '696' }
      description { 'Additional duties (safeguard)' }
      measure_type_series_id { 'J' }
    end
  end
end
