FactoryBot.define do
  factory :commodity do
    heading { attributes_for(:heading) }
    chapter { attributes_for(:chapter) }
    section { attributes_for(:section) }
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    sequence(:goods_nomenclature_sid) { |id| id }
    goods_nomenclature_item_id { sprintf '010130%04d', goods_nomenclature_sid }
    parent_sid { nil }
    producline_suffix { 80 }
    number_indents { 2 }
    meursing_code { false }
    declarable { true }

    import_measures { [] }
    export_measures { [] }
    overview_measures { [] }
    import_trade_summary {}

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

    trait :with_a_vat_overview_measure do
      overview_measures do
        [
          attributes_for(:measure, :vat),
        ]
      end
    end

    trait :with_vat_overview_measures do
      overview_measures do
        [
          attributes_for(:measure, :vat),
          attributes_for(:measure, :vat),
        ]
      end
    end

    trait :with_import_trade_summary do
      import_trade_summary do
        attributes_for(:import_trade_summary)
      end
    end

    trait :with_conditionally_prohibitive_measures do
      import_measures do
        [
          attributes_for(:measure, :conditionally_prohibitive),
        ]
      end
    end

    trait :with_prohibitive_measures do
      import_measures do
        [
          attributes_for(:measure, :prohibitive),
        ]
      end
    end

    trait :with_conditionally_prohibitive_and_prohibitive_measures do
      import_measures do
        [
          attributes_for(:measure, :prohibitive),
          attributes_for(:measure, :conditionally_prohibitive),
        ]
      end
    end
  end
end
