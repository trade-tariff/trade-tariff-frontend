module TariffChanges
  class Commodity
    include AuthenticatableApiEntity

    attr_accessor :classification_description, :goods_nomenclature_item_id, :heading, :chapter
    attr_writer :validity_end_date

    def validity_end_date
      @validity_end_date&.to_date
    end
  end
end
