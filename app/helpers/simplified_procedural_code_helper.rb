module SimplifiedProceduralCodeHelper
  def date_range_message(simplified_procedural_code)
    "#{simplified_procedural_code.validity_start_date.to_date.to_formatted_s(:long)} to #{simplified_procedural_code.validity_end_date.to_date.to_formatted_s(:long)}"
  end
end
