class SimplifiedProceduralCodeMeasureFetcherService
  Result = Data.define(
    :measures,
    :goods_nomenclature_label,
    :goods_nomenclature_item_ids,
    :validity_start_date,
    :validity_end_date,
    :validity_start_dates,
    :by_date_options,
    :by_code,
    :simplified_procedural_code,
    :no_data,
  )

  def initialize(params)
    @simplified_procedural_code = params[:simplified_procedural_code]
    @validity_start_date = params[:validity_start_date]
  end

  def call
    simplified_procedural_code ? by_code : by_date
  end

  private

  attr_reader :simplified_procedural_code

  def all
    @all ||= SimplifiedProceduralCodeMeasure.all
  end

  def by_code
    measures = SimplifiedProceduralCodeMeasure.by_code(simplified_procedural_code)
    first_measure = measures.first

    Result.new(
      measures:,
      goods_nomenclature_label: first_measure&.goods_nomenclature_label,
      goods_nomenclature_item_ids: first_measure&.goods_nomenclature_item_ids,
      validity_start_date: nil,
      validity_end_date: nil,
      validity_start_dates: nil,
      by_date_options: nil,
      by_code: true,
      simplified_procedural_code:,
      no_data: measures.all?(&:no_data?),
    )
  end

  def by_date
    Result.new(
      measures: SimplifiedProceduralCodeMeasure.by_validity_start_and_end_date(validity_start_date, validity_end_date),
      goods_nomenclature_label: nil,
      goods_nomenclature_item_ids: nil,
      validity_start_date:,
      validity_end_date:,
      validity_start_dates:,
      by_date_options:,
      by_code: false,
      simplified_procedural_code: nil,
      no_data: nil,
    )
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
