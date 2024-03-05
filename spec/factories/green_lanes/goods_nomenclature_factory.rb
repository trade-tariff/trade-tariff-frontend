FactoryBot.define do
  factory :green_lanes_goods_nomenclature, class: 'GreenLanes::GoodsNomenclature'  do
    transient do
      assessment_count { 1 }
    end

    resource_type { 'goods_nomenclature' }
    goods_nomenclature_item_id { '0100000000' }
    description { Forgery(:basic).text }
    validity_start_date { Time.zone.today.ago(3.years) }
    validity_end_date   { nil }

    applicable_category_assessments do
      attributes_for_list :category_assessment, assessment_count
    end
  end
end
