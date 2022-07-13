module QuotaDefinitionHelper
  def start_and_end_dates_for(definition)
    start_date = definition.validity_start_date
    end_date = definition.validity_end_date

    "#{start_date.to_formatted_s(:gov)} to #{end_date.to_formatted_s(:gov)}"
  end

  def suspension_period_dates_for(definition)
    if definition.suspension_period_start_date.present? && definition.suspension_period_end_date.present?
      start_date = definition.suspension_period_start_date
      end_date = definition.suspension_period_end_date

      "#{start_date.to_formatted_s(:gov)} to #{end_date.to_formatted_s(:gov)}"
    else
      'n/a'
    end
  end

  def blocking_period_dates_for(definition)
    if definition.blocking_period_start_date.present? && definition.blocking_period_end_date.present?
      start_date = definition.blocking_period_start_date
      end_date = definition.blocking_period_end_date

      "#{start_date.to_formatted_s(:gov)} to #{end_date.to_formatted_s(:gov)}"
    else
      'n/a'
    end
  end
end
