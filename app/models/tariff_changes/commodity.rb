module TariffChanges
  class Commodity
    include AuthenticatableApiEntity

    attr_accessor :classification_description, :goods_nomenclature_item_id, :heading, :chapter
  end
end
