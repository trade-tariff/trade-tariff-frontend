require 'api_entity'

class ValidityPeriod
  include ApiEntity

  attr_accessor :goods_nomenclature_item_id,
                :validity_start_date,
                :validity_end_date,
                :description,
                :formatted_description,
                :to_param,
                :goods_nomenclature_class

  has_many :deriving_goods_nomenclatures, polymorphic: true

  def start_date
    validity_start_date&.to_date
  end

  def end_date
    validity_end_date&.to_date
  end

  class << self
    def all(parent_class, parent_id, *args)
      collection "#{parent_class.collection_path}/#{parent_id}/validity_periods", *args
    end
  end
end
