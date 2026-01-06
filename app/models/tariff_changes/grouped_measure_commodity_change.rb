module TariffChanges
  class GroupedMeasureCommodityChange
    include AuthenticatableApiEntity
    include HasExcludedCountries

    set_singular_path '/uk/user/grouped_measure_commodity_changes/:id'

    attr_accessor :count, :impacted_measures

    has_one :commodity, class_name: 'TariffChanges::Commodity'
    has_one :grouped_measure_change, class_name: 'TariffChanges::GroupedMeasureChange'

    delegate :goods_nomenclature_item_id, :classification_description, :chapter, :heading, to: :commodity
    delegate :trade_direction, :geographical_area_description, :trade_direction_description, to: :grouped_measure_change
  end
end
