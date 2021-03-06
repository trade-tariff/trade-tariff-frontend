FactoryBot.define do
  factory :section do
    title    { Forgery(:basic).text }
    position { 1 }
  end

  factory :goods_nomenclature do
    description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0100000000' }
    validity_start_date { Date.today.ago(3.years) }
    validity_end_date   { nil }
  end

  factory :chapter do
    section
    description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0100000000' }
    formatted_description { Forgery(:basic).text }
  end

  factory :heading do
    chapter
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0101000000' }
  end

  factory :commodity do
    heading
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0101300000' }
    goods_nomenclature_sid { Forgery(:basic).number }
    parent_sid { Forgery(:basic).number }
  end

  factory :monetary_exchange_rate do
    child_monetary_unit_code { 'GBP' }
    exchange_rate { Random.rand.to_d.truncate(9) }
    operation_date { Date.today.at_beginning_of_month.ago(5.days).strftime('%Y-%m-%d') }
    validity_start_date { Date.today.at_beginning_of_month.strftime('%Y-%m-%d') }
  end

  factory :measure do
    transient do
      measure_type_description { Forgery(:basic).text }
    end

    origin { %w[eu uk].sample }
    ordernumber { Forgery(:basic).number(exactly: 5) }
    effective_start_date { Date.today.ago(3.years).to_s }
    effective_end_date { nil }

    measure_type do
      attributes_for(:measure_type, id: Forgery(:basic).text, description: measure_type_description).stringify_keys
    end

    trait :vat do
      measure_type do
        attributes_for(:measure_type, :vat, description: measure_type_description).stringify_keys
      end
    end

    trait :third_country do
      measure_type do
        attributes_for(:measure_type, :third_country, description: measure_type_description).stringify_keys
      end
      geographical_area { attributes_for(:geographical_area, :third_country).stringify_keys }
    end

    trait :specific_country do
      geographical_area { attributes_for(:geographical_area, :specific_country).stringify_keys }
    end

    trait :with_conditions do
      measure_conditions { [attributes_for(:measure_condition).stringify_keys] }
    end

    trait :with_additional_code do
      additional_code { attributes_for(:additional_code).stringify_keys }
    end

    trait :with_footnotes do
      footnotes { [attributes_for(:footnote).stringify_keys] }
    end

    trait :national do
      origin { 'uk' }
    end

    trait :eu do
      origin { 'eu' }
    end
  end

  factory :duty_expression do
    base { '80.50 EUR / Hectokilogram' }
    formatted_base { "80.50 EUR / <abbr title='Hectokilogram'>Hectokilogram</abbr>" }
    national_measurement_units { nil }
  end

  factory :measure_type do
    id { Forgery(:basic).text(exactly: 3) }
    description { Forgery(:basic).text }

    trait :vat do
      description { 'VAT' }
    end

    trait :third_country do
      id { '103' }
    end
  end

  factory :geographical_area do
    id { Forgery(:basic).text(exactly: 2).upcase }
    description { Forgery(:basic).text }

    trait :third_country do
      id { '1011' }
    end

    trait :specific_country do
      description { Forgery(:basic).text }
    end

    trait :with_children do
      children_geographical_areas { [attributes_for(:geograpical_area).stringify_keys] }
    end
  end

  factory :measure_condition do
    document_code { Forgery(:basic).text }
    action { Forgery(:basic).text }
    condition { Forgery(:basic).text }
    requirement_type { Forgery(:basic).text }
  end

  factory :additional_code do
    code { Forgery(:basic).text }
    description { Forgery(:basic).text }
  end

  factory :footnote do
    code { Forgery(:basic).text }
    description { Forgery(:basic).text }
  end

  factory :tariff_update do
    update_type do
      %w[TariffSynchronizer::ChiefUpdate TariffSynchronizer::TaricUpdate].sample
    end
    state { 'A' }
    created_at { Time.now.to_s }
    updated_at { Time.now.to_s }
    filename { 'filename.txt' }

    trait :chief do
      update_type { 'TariffSynchronizer::ChiefUpdate' }
    end

    trait :taric do
      update_type { 'TariffSynchronizer::TaricUpdate' }
    end
  end
end
