require 'api_entity'

class SimplifiedProceduralCodeMeasure
  include ApiEntity

  collection_path '/simplified_procedural_code_measures'

  attr_accessor :validity_start_date,
                :validity_end_date,
                :goods_nomenclature_item_ids,
                :goods_nomenclature_label,
                :duty_amount,
                :monetary_unit_code,
                :measurement_unit_code,
                :measurement_unit_qualifier_code

  def no_data?
    duty_amount.blank?
  end

  def sensible_date_range?
    validity_start_date.present? &&
      validity_end_date.present? &&
      distance_between_dates_in_days >= 12
  end

  def presented_monetary_unit
    if monetary_unit_code == 'GBP'
      '£'
    else
      '€'
    end
  end

  class << self
    def by_validity_start_and_end_date(validity_start_date, validity_end_date)
      from_date = validity_start_date
      to_date = validity_end_date

      all(filter: { to_date:, from_date: }).sort_by(&:goods_nomenclature_label)
    end

    def by_code(simplified_procedural_code)
      all(filter: { simplified_procedural_code: }).sort_by(&:validity_start_date).reverse
    end
  end

  private

  def distance_between_dates_in_days
    (validity_end_date.to_date - validity_start_date.to_date).to_i
  end
end
