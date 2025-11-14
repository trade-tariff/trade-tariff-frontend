FactoryBot.define do
  factory :subscription_target do
    target_type { 'my_commodities' }
    chapter_short_code { '11' }
    goods_nomenclature_item_id { '1234567890' }
    hierarchical_description { 'Food and Tobacco' }
    meta do
      {
        pagination: {
          page: 2,
          per_page: 10,
          total_count: 61,
        },
      }
    end
  end
end
