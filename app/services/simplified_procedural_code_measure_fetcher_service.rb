class SimplifiedProceduralCodeMeasureFetcherService
  def initialize(params)
    @simplified_procedural_code = params[:simplified_procedural_code]
    @validity_start_date = params[:validity_start_date]
    @result = OpenStruct.new do
      attr_accessor :measures,
                    :goods_nomenclature_label,
                    :goods_nomenclature_item_ids,
                    :validity_start_date,
                    :validity_end_date,
                    :validity_start_dates,
                    :by_date_options,
                    :by_code,
                    :simplified_procedural_code,
                    :no_data
    end
  end

  def call
    if simplified_procedural_code
      by_code
    else
      by_date
    end

    result
  end

  private

  attr_reader :simplified_procedural_code, :result

  def all
    @all ||= SimplifiedProceduralCodeMeasure.all
  end

  def by_code
    result.measures = SimplifiedProceduralCodeMeasure.by_code(simplified_procedural_code)
    result.goods_nomenclature_label = result.measures.first.goods_nomenclature_label
    result.goods_nomenclature_item_ids = result.measures.first.goods_nomenclature_item_ids
    result.by_code = true
    result.no_data = result.measures.all?(&:no_data?)
    result.simplified_procedural_code = simplified_procedural_code
  end

  def by_date
    result.measures = SimplifiedProceduralCodeMeasure.by_validity_start_and_end_date(validity_start_date, validity_end_date)
    result.validity_start_dates = validity_start_dates
    result.validity_start_date = validity_start_date
    result.validity_end_date = validity_end_date
    result.by_date_options = by_date_options
    result.by_code = false
  end

  def validity_start_date
    @validity_start_date.presence || validity_start_dates.max
  end

  def validity_end_date
    all_date_ranges[validity_start_date]
  end

  def validity_start_dates
    all_date_ranges.keys.uniq.compact.sort.reverse
  end

  def all_date_ranges
    @all_date_ranges ||= all.select(&:sensible_date_range?).each_with_object({}) do |measure, acc|
      acc[measure.validity_start_date] = measure.validity_end_date
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
end
