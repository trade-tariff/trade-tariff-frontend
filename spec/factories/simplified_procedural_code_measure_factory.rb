FactoryBot.define do
  factory :simplified_procedural_code_measure do
    validity_start_date { '2023-02-17' }
    validity_end_date { '2023-03-02' }
    duty_amount { 67.94 }
    goods_nomenclature_label { 'Pink grapefruit and pomelos' }
    goods_nomenclature_item_ids { '0805400019, 0805400039' }
    monetary_unit_code { 'GBP' }
    measurement_unit_code { 'NAR' }
    measurement_unit_qualifier_code { nil }
  end
end
