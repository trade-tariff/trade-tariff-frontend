module QuotaDefinitionHelper
  def start_and_end_dates_for(definition)
    govuk_date_range definition.validity_start_date, definition.validity_end_date
  end
end
