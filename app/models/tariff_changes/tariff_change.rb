module TariffChanges
  class TariffChange
    include AuthenticatableApiEntity

    attr_accessor :classification_description, :goods_nomenclature_item_id, :date_of_effect
  end
end
