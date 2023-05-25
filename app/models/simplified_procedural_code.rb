require 'api_entity'

class SimplifiedProceduralCode
  include ApiEntity

  collection_path '/simplified_procedural_code_measures'

  attr_accessor :validity_start_date, :validity_end_date, :goods_nomenclature_item_ids, :goods_nomenclature_label, :duty_amount

  def self.valid_start_dates
    all.map(&:validity_start_date).uniq.compact
  end

  def self.by_valid_start_date(validity_start_date)
    all(filter: { from_date: validity_start_date })
  end
end
