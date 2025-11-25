module TariffChanges
  class CommodityChange
    include AuthenticatableApiEntity

    set_collection_path '/uk/user/commodity_changes'

    attr_accessor :description, :count
  end
end
