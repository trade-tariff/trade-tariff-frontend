FactoryBot.define do
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

    id { 'foo'}

    validity_start_date { (months_ago || 1).months.ago }

    validity_end_date do
      if months_ago && months_ago > 1
        (months_ago - 1).months.ago - 1.day
      end
    end

    trait :subheading do
      goods_nomenclature_item_id { '0101999999' }
      producline_suffix { '80' }
      goods_nomenclature_class { 'Subheading' }

      to_param { "#{goods_nomenclature_item_id}-#{producline_suffix}" }
    end

    trait :commodity do
      goods_nomenclature_item_id { '0101999999' }
      producline_suffix { '80' }
      goods_nomenclature_class { 'Commodity' }

      to_param { goods_nomenclature_item_id }
    end
  end
end
