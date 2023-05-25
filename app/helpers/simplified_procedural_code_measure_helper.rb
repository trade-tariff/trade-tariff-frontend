module SimplifiedProceduralCodeMeasureHelper
  def date_range_message(validity_start_date, validity_end_date)
    "#{validity_start_date.to_date.to_formatted_s(:long)} to #{validity_end_date.to_date.to_formatted_s(:long)}"
  end
end
