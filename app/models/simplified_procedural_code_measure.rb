require 'api_entity'

class SimplifiedProceduralCodeMeasure
  include ApiEntity

  collection_path '/simplified_procedural_code_measures'

  attr_accessor :validity_start_date,
                :validity_end_date,
                :goods_nomenclature_item_ids,
                :goods_nomenclature_label,
                :monetary_unit_code,
                :measurement_unit_code,
                :measurement_unit_qualifier_code

  attr_writer :duty_amount

  class << self
    def by_valid_start_date(validity_start_date)
      validity_start_date = maximum_validity_start_date if validity_start_date.blank?

      from_date = validity_start_date
      to_date = all_date_options[validity_start_date]

      all(filter: { to_date:, from_date: }).sort_by(&:goods_nomenclature_label)
    end

    def by_code(simplified_procedural_code)
      all(filter: { simplified_procedural_code: }).sort_by(&:validity_start_date).reverse
    end

    def validity_start_dates
      all_date_options.keys.uniq.compact.sort.reverse
    end

    def all_date_options
      all.select(&:validity_start_date).each_with_object({}) do |simplified_procedural_code_measure, acc|
        if simplified_procedural_code_measure.validity_start_date
          acc[simplified_procedural_code_measure.validity_start_date] = simplified_procedural_code_measure.validity_end_date
        end
      end
    end

    def by_date_options
      validity_start_dates.map do |validity_start_date|
        [
          validity_start_date.to_date.to_formatted_s(:short),
          validity_start_date,
        ]
      end
    end

    private

    def maximum_validity_start_date
      all_date_options.keys.max
    end
  end

  def by_code_duty_amount
    if duty_amount == '—'
      '—'
    else
      "#{presented_monetary_unit}#{duty_amount}"
    end
  end

  def duty_amount
    @duty_amount.presence || '—'
  end

  private

  def presented_monetary_unit
    if monetary_unit_code == 'GBP'
      '£'
    else
      '€'
    end
  end
end
