require 'api_entity'

class ChemicalSubstance
  include ApiEntity

  collection_path '/chemical_substances'

  attr_accessor :cus,
                :cas_rn,
                :goods_nomenclature_sid,
                :goods_nomenclature_item_id,
                :producline_suffix,
                :name,
                :nomen

  enum :nomen, {
    ci: %w[CI],
    common: %w[COMMON],
    inci: %w[INCI],
    inn: %w[INN],
    innm: %w[INNM],
    iso: %w[ISO],
    isom: %w[ISOM],
    iubmb: %w[IUBMB],
    iupac: %w[IUPAC],
    iupac_gen1: %w[IUPAC-GEN1],
  }

  def self.by_sid(goods_nomenclature_sid)
    all(filter: { goods_nomenclature_sid: })
  end
end
