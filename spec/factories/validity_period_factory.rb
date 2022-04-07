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

    validity_start_date { (months_ago || 1).months.ago }

    validity_end_date do
      if months_ago && months_ago > 1
        (months_ago - 1).months.ago - 1.day
      end
    end
  end
end
