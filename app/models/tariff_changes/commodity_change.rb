module TariffChanges
  class CommodityChange
    include AuthenticatableApiEntity

    set_singular_path '/uk/user/commodity_changes/:id'
    set_collection_path '/uk/user/commodity_changes'

    attr_accessor :description
    attr_writer :count

    has_many :tariff_changes, class_name: 'TariffChanges::TariffChange'

    def count
      @count || 0
    end
  end
end
