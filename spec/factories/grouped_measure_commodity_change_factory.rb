FactoryBot.define do
  factory :grouped_measure_commodity_change, class: 'TariffChanges::GroupedMeasureCommodityChange' do
    count { 2 }
    commodity do
      {
        'goods_nomenclature_item_id' => '1234567890',
        'classification_description' => 'Test Classification',
      }
    end
  end
end
