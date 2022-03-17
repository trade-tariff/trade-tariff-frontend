FactoryBot.define do
  factory :section do
    title    { Forgery(:basic).text }
    position { 1 }
  end

  factory :goods_nomenclature do
    description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0100000000' }
    goods_nomenclature_id { '0100000000' }
    goods_nomenclature_class { 'Chapter' }
    validity_start_date { Time.zone.today.ago(3.years) }
    validity_end_date   { nil }
  end

  factory :chapter do
    section { attributes_for(:section) }
    description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0100000000' }
    formatted_description { Forgery(:basic).text }
  end

  factory :heading do
    chapter { attributes_for(:chapter) }
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0101000000' }

    commodities { [] }
    import_measures { [] }
    export_measures { [] }

    initialize_with do
      new(attributes)
    end
  end

  factory :subheading do
    section { attributes_for(:section) }
    chapter { attributes_for(:chapter) }
    commodities { [] }

    goods_nomenclature_item_id { '0101100000' }
    producline_suffix { '10' }
    goods_nomenclature_sid { 131_312 }
    number_indents { 3 }
    description { 'Horses' }
    formatted_description { '<strong>Horses</strong>' }
    declarable { false }

    trait :harmonised_system_code do
      goods_nomenclature_item_id { '0101100000' }
    end

    trait :combined_nomenclature_code do
      goods_nomenclature_item_id { '0101111000' }
    end

    trait :taric_code do
      goods_nomenclature_item_id { '0101121210' }
    end

    initialize_with do
      new(attributes)
    end
  end

  factory :commodity do
    heading { attributes_for(:heading) }
    section { attributes_for(:section) }
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    sequence(:goods_nomenclature_sid) { |id| id }
    goods_nomenclature_item_id { sprintf '010130%04d', goods_nomenclature_sid }
    parent_sid { nil }
    number_indents { 2 }
    meursing_code { false }

    import_measures { [] }
    export_measures { [] }

    meta do
      {
        'duty_calculator' => {
          'applicable_additional_codes' => {},
          'applicable_measure_units' => {},
          'applicable_vat_options' => {
            'VATZ' => 'VAT zero rate',
          },
          'entry_price_system' => false,
          'meursing_code' => false,
          'source' => 'uk',
          'trade_defence' => false,
          'zero_mfn_duty' => false,
        },
      }
    end

    initialize_with do
      new(attributes)
    end
  end

  factory :order_number do
    number { Forgery(:basic).number(exactly: 6).to_s }
  end

  factory :definition, class: 'OrderNumber::Definition' do
    quota_definition_sid { Forgery(:basic).number }
    initial_volume { '54000.0' }
    validity_start_date { '2021-01-01T00:00:00.000Z' }
    validity_end_date { '2021-12-31T00:00:00.000Z' }
    status { 'Open' }
    description { nil }
    balance { '54000.0' }
    measurement_unit { 'Kilogram (kg)' }
    monetary_unit { nil }
    measurement_unit_qualifier { nil }
    last_allocation_date { nil }
    suspension_period_start_date { nil }
    suspension_period_end_date { nil }
    blocking_period_start_date { nil }
    blocking_period_end_date { nil }
    order_number { attributes_for(:order_number) }
  end

  factory :measure do
    transient do
      measure_type_description { Forgery(:basic).text }
      measure_type_id { Forgery(:basic).text }
      geographical_area_id { 'FR' }
    end

    origin { %w[eu uk].sample }
    effective_start_date { Time.zone.today.ago(3.years).to_s }
    effective_end_date { nil }

    measure_type do
      attributes_for(:measure_type, id: measure_type_id, description: measure_type_description)
    end

    geographical_area do
      attributes_for(:geographical_area, id: geographical_area_id)
    end

    trait :vat do
      vat { true }
    end

    trait :erga_omnes do
      geographical_area { attributes_for(:geographical_area, :erga_omnes) }
    end

    trait :vat_excise do
      measure_type do
        attributes_for(:measure_type, :vat_excise, description: measure_type_description)
      end
    end

    trait :trade_remedies do
      measure_type do
        attributes_for(:measure_type, :trade_remedies, description: measure_type_description)
      end
    end

    trait :import_controls do
      measure_type do
        attributes_for(:measure_type, :import_controls, description: measure_type_description)
      end
    end

    trait :quotas do
      measure_type do
        attributes_for(:measure_type, :quotas, description: measure_type_description)
      end
    end

    trait :third_country do
      measure_type do
        attributes_for(:measure_type, :third_country, description: measure_type_description)
      end
      geographical_area { attributes_for(:geographical_area, :erga_omnes) }
    end

    trait :tariff_preference do
      measure_type do
        attributes_for(:measure_type, :tariff_preference, description: measure_type_description)
      end
    end

    trait :other_customs_duties do
      measure_type do
        attributes_for(:measure_type, :other_customs_duties, description: measure_type_description)
      end
    end

    trait :excluded do
      measure_type do
        attributes_for(:measure_type, :excluded, description: measure_type_description).stringify_keys
      end
    end

    trait :unclassified do
      measure_type do
        attributes_for(:measure_type, :unclassified, description: measure_type_description).stringify_keys
      end
    end

    trait :unclassified_import_control do
      measure_type do
        attributes_for(:measure_type, :unclassified, :unclassified_import_control, description: measure_type_description).stringify_keys
      end
    end

    trait :unclassified_customs_duties do
      measure_type do
        attributes_for(:measure_type, :unclassified, :unclassified_customs_duties, description: measure_type_description).stringify_keys
      end
    end

    trait :import_export_supplementary do
      measure_type do
        attributes_for(:measure_type, :import_export_supplementary, description: measure_type_description)
      end

      duty_expression do
        attributes_for(:duty_expression, base: 'p/st')
      end
    end

    trait :import_only_supplementary do
      measure_type do
        attributes_for(:measure_type, :import_only_supplementary, description: measure_type_description)
      end

      duty_expression do
        attributes_for(:duty_expression, base: 'p/st')
      end
    end

    trait :with_supplementary_measure_components do
      measure_components do
        [attributes_for(:measure_component, :with_supplementary_measurement_unit)]
      end
    end

    trait :with_eu_member_exclusions do
      excluded_countries do
        [
          { 'id' => 'AT', 'description' => 'Austria', 'geographical_area_id' => 'AT' },
          { 'id' => 'BE', 'description' => 'Belgium', 'geographical_area_id' => 'BE' },
          { 'id' => 'BG', 'description' => 'Bulgaria', 'geographical_area_id' => 'BG' },
          { 'id' => 'CH', 'description' => 'Switzerland', 'geographical_area_id' => 'CH' },
          { 'id' => 'CY', 'description' => 'Cyprus', 'geographical_area_id' => 'CY' },
          { 'id' => 'CZ', 'description' => 'Czechia', 'geographical_area_id' => 'CZ' },
          { 'id' => 'DE', 'description' => 'Germany', 'geographical_area_id' => 'DE' },
          { 'id' => 'DK', 'description' => 'Denmark', 'geographical_area_id' => 'DK' },
          { 'id' => 'EE', 'description' => 'Estonia', 'geographical_area_id' => 'EE' },
          { 'id' => 'ES', 'description' => 'Spain', 'geographical_area_id' => 'ES' },
          { 'id' => 'EU', 'description' => 'European Union', 'geographical_area_id' => 'EU' },
          { 'id' => 'FI', 'description' => 'Finland', 'geographical_area_id' => 'FI' },
          { 'id' => 'FR', 'description' => 'France', 'geographical_area_id' => 'FR' },
          { 'id' => 'GR', 'description' => 'Greece', 'geographical_area_id' => 'GR' },
          { 'id' => 'HR', 'description' => 'Croatia', 'geographical_area_id' => 'HR' },
          { 'id' => 'HU', 'description' => 'Hungary', 'geographical_area_id' => 'HU' },
          { 'id' => 'IE', 'description' => 'Ireland', 'geographical_area_id' => 'IE' },
          { 'id' => 'IS', 'description' => 'Iceland', 'geographical_area_id' => 'IS' },
          { 'id' => 'IT', 'description' => 'Italy', 'geographical_area_id' => 'IT' },
          { 'id' => 'LI', 'description' => 'Liechtenstein', 'geographical_area_id' => 'LI' },
          { 'id' => 'LT', 'description' => 'Lithuania', 'geographical_area_id' => 'LT' },
          { 'id' => 'LU', 'description' => 'Luxembourg', 'geographical_area_id' => 'LU' },
          { 'id' => 'LV', 'description' => 'Latvia', 'geographical_area_id' => 'LV' },
          { 'id' => 'MT', 'description' => 'Malta', 'geographical_area_id' => 'MT' },
          { 'id' => 'NL', 'description' => 'Netherlands', 'geographical_area_id' => 'NL' },
          { 'id' => 'NO', 'description' => 'Norway', 'geographical_area_id' => 'NO' },
          { 'id' => 'PL', 'description' => 'Poland', 'geographical_area_id' => 'PL' },
          { 'id' => 'PT', 'description' => 'Portugal', 'geographical_area_id' => 'PT' },
          { 'id' => 'RO', 'description' => 'Romania', 'geographical_area_id' => 'RO' },
          { 'id' => 'SE', 'description' => 'Sweden', 'geographical_area_id' => 'SE' },
          { 'id' => 'SI', 'description' => 'Slovenia', 'geographical_area_id' => 'SI' },
          { 'id' => 'SK', 'description' => 'Slovakia', 'geographical_area_id' => 'SK' },
        ]
      end
    end

    trait :with_exclusions do
      excluded_countries do
        [
          { 'id' => 'CH', 'description' => 'Switzerland', 'geographical_area_id' => 'CH' },
          { 'id' => 'CY', 'description' => 'Cyprus', 'geographical_area_id' => 'CY' },
          { 'id' => 'CZ', 'description' => 'Czechia', 'geographical_area_id' => 'CZ' },
        ]
      end
    end

    trait :specific_country do
      geographical_area { attributes_for(:geographical_area, :specific_country) }
    end

    trait :with_conditions do
      measure_conditions { [attributes_for(:measure_condition)] }
    end

    trait :with_additional_code do
      additional_code { attributes_for(:additional_code) }
    end

    trait :with_footnotes do
      footnotes { [attributes_for(:footnote)] }
    end

    trait :national do
      origin { 'uk' }
    end

    trait :eu do
      origin { 'eu' }
    end

    trait :import do
      import { true }
    end

    trait :export do
      import { false }
    end

    initialize_with do
      new(attributes)
    end
  end

  factory :legal_act do
    published_date { Time.zone.today.iso8601 }
    officialjournal_number {}
    officialjournal_page {}
    validity_start_date {}
    validity_end_date {}

    regulation_code { 'S.I. 2020/1432' }
    regulation_url { 'https://www.legislation.gov.uk/uksi/2020/1432' }
    description { 'The Customs Tariff (Preferential Trade Arrangements) (EU Exit) (Amendment) Regulations 2021' }
  end

  factory :duty_expression do
    base { '80.50 EUR / Hectokilogram' }
    formatted_base { "80.50 EUR / <abbr title='Hectokilogram'>Hectokilogram</abbr>" }

    trait :supplementary do
      description { 'Number of items' }
    end
  end

  factory :measure_type do
    id { Forgery(:basic).text(exactly: 3) }
    description { Forgery(:basic).text }

    trait :vat do
      description { 'VAT' }
    end

    trait :vat_excise do
      id { '305' }
    end

    trait :import_controls do
      id { '277' }
    end

    trait :trade_remedies do
      id { '551' }
    end

    trait :quotas do
      id { '122' }
    end

    trait :third_country do
      id { '103' }
    end

    trait :tariff_preference do
      id { '142' }
    end

    trait :other_customs_duties do
      id { '109' }
    end

    trait :excluded do
      id { '430' }
    end

    trait :unclassified do
      id { 'FOO' }
    end

    trait :import_export_supplementary do
      id { '109' }
    end

    trait :import_only_supplementary do
      id { '110' }
    end

    trait :export_only_supplementary do
      id { '111' }
    end

    trait :unclassified_import_control do
      measure_component_applicable_code { 2 }
    end

    trait :unclassified_customs_duties do
      measure_component_applicable_code { 1 }
    end
  end

  factory :measure_component do
    trait :with_supplementary_measurement_unit do
      duty_expression do
        attributes_for(:duty_expression, base: 'p/st')
      end

      measurement_unit do
        attributes_for(:measurement_unit, :supplementary)
      end
    end
  end

  factory :measurement_unit do
    description { Forgery(:basic).text }
    measurement_unit_code { Forgery(:basic).text(exactly: 3).upcase }

    trait :supplementary do
      description { 'Number of items' }
      measurement_unit_code { 'NAR' }
    end
  end

  factory :geographical_area do
    id { Forgery(:basic).text(exactly: 2).upcase }
    description { Forgery(:basic).text }

    trait :specific_country do
      description { Forgery(:basic).text }
    end

    trait :erga_omnes do
      id { '1011' }
    end

    initialize_with do
      new(attributes)
    end
  end

  factory :measure_condition do
    condition_code { Forgery(:basic).text(exactly: 1) }
    condition { Forgery(:basic).text }
    document_code { Forgery(:basic).text(exactly: 4) }
    requirement { Forgery(:basic).text }
    action { Forgery(:basic).text }
    duty_expression { Forgery(:basic).text }
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
    update_type { 'TariffSynchronizer::TaricUpdate' }

    state { 'A' }
    created_at { Time.zone.now.iso8601 }
    updated_at { Time.zone.now.iso8601 }
    applied_at { Time.zone.now.iso8601 }
    filename { 'filename.txt' }

    initialize_with do
      new(attributes)
    end
  end

  factory :rules_of_origin_link, class: 'RulesOfOrigin::Link' do
    sequence(:text) { |n| "GovUK page #{n}" }
    url { 'https://www.gov.uk' }
  end

  factory :rules_of_origin_proof, class: 'RulesOfOrigin::Proof' do
    sequence(:summary) { |n| "Proof summary #{n}" }
    url { 'https://www.gov.uk/' }
    sequence(:subtext) { |n| "Proof subtext #{n}" }
  end

  factory :rules_of_origin_rule, class: 'RulesOfOrigin::Rule' do
    sequence(:id_rule) { |n| n }
    sequence(:heading) { |n| "Chapter #{n}" }
    description { 'Description' }
    rule { 'Rule' }
  end

  factory :rules_of_origin_scheme, class: 'RulesOfOrigin::Scheme' do
    transient do
      rule_count { 3 }
      link_count { 2 }
    end

    sequence(:scheme_code) { |n| "SC#{n}" }
    sequence(:title) { |n| "Scheme title #{n}" }
    countries { %w[FR ES IT] }
    footnote { 'Scheme footnote' }
    unilateral { nil }
    fta_intro { "## Agreement\n\nDetails of agreement" }
    introductory_notes { "## Introductory notes\n\nDetails of introductory notes" }
    rules { attributes_for_list :rules_of_origin_rule, rule_count }
    links { attributes_for_list :rules_of_origin_link, link_count }
  end

  factory :news_item do
    sequence(:id) { |n| n }
    start_date { Time.zone.yesterday }
    sequence(:title) { |n| "News item #{n}" }
    display_style { NewsItem::DISPLAY_STYLE_REGULAR }
    show_on_xi { true }
    show_on_uk { true }
    show_on_updates_page { false }
    show_on_home_page { true }

    content do
      <<~CONTENT
        This is some **body** content

        1. With
        2. A list
        3. In it
      CONTENT
    end

    trait :uk_only do
      show_on_xi { false }
    end

    trait :xi_only do
      show_on_uk { false }
    end

    trait :homepage do
      show_on_updates_page { false }
      show_on_home_page { true }
    end

    trait :updates_and_homepage do
      show_on_home_page { true }
    end
  end

  factory :search do
    transient do
      search_date {}
    end

    q { 'foo' }

    trait :with_search_date do
      search_date { Time.zone.today }

      day { search_date.day.to_s.rjust(2, '0') }
      month { search_date.month.to_s.rjust(2, '0') }
      year { search_date.year.to_s.rjust(2, '0') }
    end

    trait :with_country do
      country { 'IT' }
    end

    initialize_with do
      new(attributes)
    end
  end

  factory :validity_period do
    transient do
      goods_nomenclature { nil }
    end

    transient do
      months_ago { nil }
    end

    sequence(:goods_nomenclature_item_id) do |n|
      goods_nomenclature&.code || sprintf('0101%06d', n)
    end

    validity_start_date { (months_ago || 1).months.ago }

    validity_end_date do
      if months_ago && months_ago > 1
        (months_ago - 1).months.ago - 1.day
      end
    end

    initialize_with do
      new(attributes)
    end
  end

  factory :feedback
end
