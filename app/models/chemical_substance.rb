require 'api_entity'

class ChemicalSubstance
  include ApiEntity

  collection_path '/chemical_substances'

  attr_accessor :cus,
                :cas_rn,
                :goods_nomenclature_sid,
                :goods_nomenclature_item_id,
                :producline_suffix,
                :name

  def self.by_sid(goods_nomenclature_sid)
    all(filter: { goods_nomenclature_sid: })
  end
end
