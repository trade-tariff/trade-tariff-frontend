FactoryBot.define do
  factory :ancestor, class: 'GoodsNomenclature' do
    goods_nomenclature_item_id {}
    goods_nomenclature_class {}
    description {}
    producline_suffix {}

    initialize_with do
      goods_nomenclature_class.constantize.new(
        goods_nomenclature_item_id:,
        description:,
        producline_suffix:,
      )
    end

    trait :chapter do
      goods_nomenclature_item_id { '0100000000' }
      goods_nomenclature_class { 'Chapter' }
      description { 'Live animals' }
      description_indexed { 'Live animals' }
      producline_suffix { '80' }
    end

    trait :heading do
      goods_nomenclature_item_id { '0101000000' }
      goods_nomenclature_class { 'Heading' }
      description { 'Live horses, asses, mules and hinnies' }
      description_indexed { 'Live horses, asses, mules and hinnies' }
      producline_suffix { '80' }
    end

    trait :subheading do
      goods_nomenclature_item_id { '0101210000' }
      goods_nomenclature_class { 'Subheading' }
      description { 'Live horses, asses, mules and hinnies' }
      description_indexed { 'Live horses, asses, mules and hinnies' }
      producline_suffix { '10' }
    end
  end
end
