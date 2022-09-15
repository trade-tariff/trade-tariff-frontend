require 'api_entity'

class ValidityPeriod
  include ApiEntity

  attr_accessor :goods_nomenclature_item_id,
                :validity_start_date,
                :validity_end_date,
                :to_param,
                :goods_nomenclature_class

  def start_date
    validity_start_date&.to_date
  end

  def end_date
    validity_end_date&.to_date
  end

  class << self
    def all(parent_class, parent_id, *args)
      collection collection_path(parent_class, parent_id), *args
    end

    private

    def collection_path(parent_class, parent_id)
      "#{parent_class.collection_path}/#{parent_id}/validity_periods"
    end
  end
end
