module TariffChanges
  class GroupedMeasureCommodityChange
    include AuthenticatableApiEntity
    include HasExcludedCountries

    set_singular_path '/uk/user/grouped_measure_commodity_changes/:id'

    attr_accessor :count

    has_one :commodity, class_name: 'TariffChanges::Commodity'
  end
end
